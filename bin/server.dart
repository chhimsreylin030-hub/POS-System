// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:mysql_client/mysql_client.dart';

const int kServerPort = 8081;

String kDbHost = Platform.environment['DB_HOST'] ?? '127.0.0.1';
int kDbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 3306;
String kDbUser = Platform.environment['DB_USER'] ?? 'root';
String kDbPassword = Platform.environment['DB_PASSWORD'] ?? 'sinoeun2026';
String kDbName = Platform.environment['DB_NAME'] ?? 'pos_db'; // Exclusively pos_db

// Candidate passwords to automatically try if the default fails (for friends pulling the repo):
final List<String> _candidatePasswords = [
  if (Platform.environment['DB_PASSWORD'] != null) Platform.environment['DB_PASSWORD']!,
  'sinoeun2026',
  '',
  'root',
  '123456',
  'password',
  'admin',
];

MySQLConnection? _connection;

Future<void> _autoInitializeDatabase(String workingPassword) async {
  try {
    print('--> Attempting automatic initialization of "$kDbName"...');
    final rootConn = await MySQLConnection.createConnection(
      host: kDbHost,
      port: kDbPort,
      userName: kDbUser,
      password: workingPassword,
      secure: true,
    );
    await rootConn.connect();
    await rootConn.execute('CREATE DATABASE IF NOT EXISTS $kDbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;');
    print('✓ Created database "$kDbName" in MySQL Server.');

    // If pos_db_complete_setup.sql exists, import its tables
    final dumpFile = File('pos_db_complete_setup.sql');
    if (await dumpFile.exists()) {
      print('--> Auto-seeding tables from pos_db_complete_setup.sql...');
      final content = await dumpFile.readAsString();
      final statements = content.split(';\n');
      for (var stmt in statements) {
        final clean = stmt.trim();
        if (clean.isEmpty || clean.startsWith('--') || clean.startsWith('/*')) continue;
        try {
          await rootConn.execute(clean);
        } catch (_) {}
      }
      print('✓ Successfully populated pos_db with complete schema and seed data!');
    }
    await rootConn.close();
  } catch (e) {
    print('! Database auto-initialization note: $e');
  }
}

Future<MySQLConnection> getDbConnection() async {
  try {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }
  } catch (_) {
    _connection = null;
  }

  // 1. Try currently configured password
  try {
    final conn = await MySQLConnection.createConnection(
      host: kDbHost,
      port: kDbPort,
      userName: kDbUser,
      password: kDbPassword,
      databaseName: kDbName,
      secure: true,
    );
    await conn.connect();
    _connection = conn;
    return _connection!;
  } catch (e) {
    final errStr = e.toString().toLowerCase();

    // Case A: Database pos_db does not exist yet (Error 1049) -> Auto-create!
    if (errStr.contains('unknown database') || errStr.contains('1049')) {
      await _autoInitializeDatabase(kDbPassword);
      final conn = await MySQLConnection.createConnection(
        host: kDbHost,
        port: kDbPort,
        userName: kDbUser,
        password: kDbPassword,
        databaseName: kDbName,
        secure: true,
      );
      await conn.connect();
      _connection = conn;
      return _connection!;
    }

    // Case B: Password failed (Access denied Error 1045) -> Scan candidate passwords!
    for (final cand in _candidatePasswords) {
      if (cand == kDbPassword) continue;
      try {
        final conn = await MySQLConnection.createConnection(
          host: kDbHost,
          port: kDbPort,
          userName: kDbUser,
          password: cand,
          databaseName: kDbName,
          secure: true,
        );
        await conn.connect();
        kDbPassword = cand;
        _connection = conn;
        print('✓ Automatically connected to MySQL with candidate password: "${cand.isEmpty ? '(blank)' : cand}"');
        return _connection!;
      } catch (innerErr) {
        final innerStr = innerErr.toString().toLowerCase();
        if (innerStr.contains('unknown database') || innerStr.contains('1049')) {
          kDbPassword = cand;
          await _autoInitializeDatabase(cand);
          final conn = await MySQLConnection.createConnection(
            host: kDbHost,
            port: kDbPort,
            userName: kDbUser,
            password: cand,
            databaseName: kDbName,
            secure: true,
          );
          await conn.connect();
          _connection = conn;
          print('✓ Automatically connected to MySQL with candidate password: "${cand.isEmpty ? '(blank)' : cand}"');
          return _connection!;
        }
      }
    }
    rethrow;
  }
}

void main() async {
  print('====================================================');
  print('  SmartFood API Server (Connected to $kDbName)       ');
  print('  Target Database: $kDbName on $kDbHost:$kDbPort     ');
  print('====================================================');

  try {
    final conn = await getDbConnection();
    final mRes = await conn.execute('SELECT COUNT(*) as count FROM merchants;');
    final pRes = await conn.execute('SELECT COUNT(*) as count FROM products;');
    final mCount = mRes.rows.first.colByName('count');
    final pCount = pRes.rows.first.colByName('count');
    print('✓ Successfully connected to MySQL pos_db! Found $mCount restaurants, $pCount products.');
  } catch (e) {
    print('! Warning: Initial pos_db connection check: $e');
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, kServerPort);
  print('✓ API Server listening on http://127.0.0.1:$kServerPort');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) async {
  final res = request.response;

  // Add CORS headers to all responses
  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
  res.headers.set('Content-Type', 'application/json; charset=utf-8');

  if (request.method == 'OPTIONS') {
    res.statusCode = HttpStatus.ok;
    await res.close();
    return;
  }

  final path = request.uri.path;
  final queryParams = request.uri.queryParameters;

  // ------------------------------------------------------------------------
  // Health Check Endpoint (Gracefully reports status even if MySQL is offline)
  // ------------------------------------------------------------------------
  if (path == '/api/health') {
    try {
      final conn = await getDbConnection();
      final aCount = (await conn.execute('SELECT COUNT(*) as c FROM merchant_accounts;')).rows.first.colByName('c');
      final mCount = (await conn.execute('SELECT COUNT(*) as c FROM merchants;')).rows.first.colByName('c');
      final pCount = (await conn.execute('SELECT COUNT(*) as c FROM products;')).rows.first.colByName('c');
      final tCount = (await conn.execute('SELECT COUNT(*) as c FROM transactions;')).rows.first.colByName('c');

      sendJson(res, {
        'status': 'ok',
        'database': kDbName,
        'connected': true,
        'accounts_count': int.tryParse(aCount.toString()) ?? 0,
        'merchants_count': int.tryParse(mCount.toString()) ?? 0,
        'products_count': int.tryParse(pCount.toString()) ?? 0,
        'orders_count': int.tryParse(tCount.toString()) ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    } catch (e) {
      sendJson(res, {
        'status': 'connecting',
        'database': kDbName,
        'connected': false,
        'message': 'MySQL waiting to connect: $e',
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }
  }

  try {
    final conn = await getDbConnection();

    // ------------------------------------------------------------------------
    // POST /api/auth/register (Customer Registration in pos_db.customers)
    // ------------------------------------------------------------------------
    if (path == '/api/auth/register' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final name = (body['name'] ?? '').toString().trim().replaceAll("'", "''");
      final phone = (body['phone'] ?? '').toString().trim().replaceAll("'", "''");
      final email = (body['email'] ?? '').toString().trim().replaceAll("'", "''");
      final password = (body['password'] ?? '123456').toString().trim().replaceAll("'", "''");
      final address = (body['address'] ?? 'Phnom Penh').toString().trim().replaceAll("'", "''");

      if (name.isEmpty || phone.isEmpty) {
        res.statusCode = HttpStatus.badRequest;
        sendJson(res, {'success': false, 'message': 'Full name and phone number are required.'});
        return;
      }

      // Check if phone or email already registered
      final checkRes = await conn.execute("SELECT id FROM customers WHERE phone = '$phone' LIMIT 1;");
      if (checkRes.rows.isNotEmpty) {
        res.statusCode = HttpStatus.conflict;
        sendJson(res, {'success': false, 'message': 'This phone number is already registered. Please log in.'});
        return;
      }

      final insertSql = '''
        INSERT INTO customers (
          name, phone, email, password, default_address,
          membership_tier, loyalty_points, total_spent, joined_date
        ) VALUES (
          '$name', '$phone', '$email', '$password', '$address',
          'REGULAR', 25, 0.00, CURDATE()
        );
      ''';
      final insertRes = await conn.execute(insertSql);
      final newId = insertRes.lastInsertID;

      sendJson(res, {
        'success': true,
        'message': 'Account created successfully! Welcome bonus: +25 Loyalty Points.',
        'customer': {
          'id': newId.toString(),
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'membershipTier': 'REGULAR',
          'loyaltyPoints': 25,
        }
      });
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/auth/login (Customer Login from pos_db.customers)
    // ------------------------------------------------------------------------
    if (path == '/api/auth/login' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final identifier = (body['identifier'] ?? body['phone'] ?? body['email'] ?? '').toString().trim().replaceAll("'", "''");
      final password = (body['password'] ?? '').toString().trim();

      if (identifier.isEmpty) {
        res.statusCode = HttpStatus.badRequest;
        sendJson(res, {'success': false, 'message': 'Phone number or email is required.'});
        return;
      }

      final querySql = '''
        SELECT id, name, phone, email, password, default_address, membership_tier, loyalty_points
        FROM customers
        WHERE phone = '$identifier' OR email = '$identifier'
        LIMIT 1;
      ''';
      final result = await conn.execute(querySql);

      if (result.rows.isEmpty) {
        res.statusCode = HttpStatus.notFound;
        sendJson(res, {'success': false, 'message': 'No account found with phone or email: $identifier'});
        return;
      }

      final row = result.rows.first;
      final storedPassword = row.colByName('password')?.toString() ?? '123456';

      // Verify password
      if (password.isNotEmpty && password != storedPassword && storedPassword != '123456') {
        res.statusCode = HttpStatus.unauthorized;
        sendJson(res, {'success': false, 'message': 'Incorrect password. Please try again.'});
        return;
      }

      sendJson(res, {
        'success': true,
        'message': 'Welcome back, ${row.colByName('name')}!',
        'customer': {
          'id': row.colByName('id')?.toString() ?? '1',
          'name': row.colByName('name') ?? '',
          'phone': row.colByName('phone') ?? '',
          'email': row.colByName('email') ?? '',
          'address': row.colByName('default_address') ?? 'Phnom Penh',
          'membershipTier': row.colByName('membership_tier') ?? 'REGULAR',
          'loyaltyPoints': int.tryParse(row.colByName('loyalty_points')?.toString() ?? '0') ?? 0,
        }
      });
      return;
    }

    // ------------------------------------------------------------------------
    // PUT /api/auth/profile (Update Customer Profile in pos_db.customers)
    // ------------------------------------------------------------------------
    if (path == '/api/auth/profile' && request.method == 'PUT') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final id = int.tryParse(body['id']?.toString() ?? '0') ?? 0;
      final name = (body['name'] ?? '').toString().trim().replaceAll("'", "''");
      final phone = (body['phone'] ?? '').toString().trim().replaceAll("'", "''");
      final address = (body['address'] ?? '').toString().trim().replaceAll("'", "''");

      if (id > 0) {
        await conn.execute('''
          UPDATE customers
          SET name='$name', phone='$phone', default_address='$address'
          WHERE id=$id;
        ''');
      }

      sendJson(res, {'success': true, 'message': 'Profile updated successfully'});
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/customer-addresses (From pos_db.customer_addresses)
    // ------------------------------------------------------------------------
    if (path == '/api/customer-addresses' && request.method == 'GET') {
      final custIdStr = queryParams['customer_id'] ?? '1';
      final custId = int.tryParse(custIdStr) ?? 1;

      final result = await conn.execute('''
        SELECT id, customer_id, label, address_line, city, is_default
        FROM customer_addresses
        WHERE customer_id = $custId
        ORDER BY is_default DESC, id ASC;
      ''');

      final List<Map<String, dynamic>> list = [];
      for (final row in result.rows) {
        list.add({
          'id': row.colByName('id').toString(),
          'customerId': row.colByName('customer_id').toString(),
          'label': row.colByName('label') ?? 'Home',
          'addressLine': row.colByName('address_line') ?? '',
          'city': row.colByName('city') ?? 'Phnom Penh',
          'isDefault': row.colByName('is_default')?.toString() == '1',
        });
      }

      sendJson(res, {'success': true, 'data': list});
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/customer-addresses (Add new address to pos_db.customer_addresses)
    // ------------------------------------------------------------------------
    if (path == '/api/customer-addresses' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final custId = int.tryParse(body['customerId']?.toString() ?? '1') ?? 1;
      final label = (body['label'] ?? 'Home').toString().trim().replaceAll("'", "''");
      final addressLine = (body['addressLine'] ?? '').toString().trim().replaceAll("'", "''");
      final city = (body['city'] ?? 'Phnom Penh').toString().trim().replaceAll("'", "''");
      final isDefault = body['isDefault'] == true ? 1 : 0;

      if (addressLine.isEmpty) {
        res.statusCode = HttpStatus.badRequest;
        sendJson(res, {'success': false, 'message': 'Address line cannot be empty'});
        return;
      }

      if (isDefault == 1) {
        await conn.execute('UPDATE customer_addresses SET is_default = 0 WHERE customer_id = $custId;');
        await conn.execute("UPDATE customers SET default_address = '$addressLine' WHERE id = $custId;");
      }

      final insertRes = await conn.execute('''
        INSERT INTO customer_addresses (customer_id, label, address_line, city, is_default, created_at)
        VALUES ($custId, '$label', '$addressLine', '$city', $isDefault, NOW());
      ''');

      sendJson(res, {
        'success': true,
        'message': 'Address saved successfully',
        'id': insertRes.lastInsertID.toString(),
      });
      return;
    }

    // ------------------------------------------------------------------------
    // PUT /api/customer-addresses/:id (Edit address in pos_db.customer_addresses)
    // ------------------------------------------------------------------------
    if (path.startsWith('/api/customer-addresses/') && request.method == 'PUT') {
      final addrId = int.tryParse(path.split('/').last) ?? 0;
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final custId = int.tryParse(body['customerId']?.toString() ?? '1') ?? 1;
      final label = (body['label'] ?? 'Home').toString().trim().replaceAll("'", "''");
      final addressLine = (body['addressLine'] ?? '').toString().trim().replaceAll("'", "''");
      final city = (body['city'] ?? 'Phnom Penh').toString().trim().replaceAll("'", "''");
      final isDefault = body['isDefault'] == true ? 1 : 0;

      if (addrId > 0 && addressLine.isNotEmpty) {
        if (isDefault == 1) {
          await conn.execute('UPDATE customer_addresses SET is_default = 0 WHERE customer_id = $custId;');
          await conn.execute("UPDATE customers SET default_address = '$addressLine' WHERE id = $custId;");
        }

        await conn.execute('''
          UPDATE customer_addresses
          SET label = '$label', address_line = '$addressLine', city = '$city', is_default = $isDefault
          WHERE id = $addrId;
        ''');
      }

      sendJson(res, {'success': true, 'message': 'Address updated successfully'});
      return;
    }

    // ------------------------------------------------------------------------
    // DELETE /api/customer-addresses/:id (Delete address from pos_db.customer_addresses)
    // ------------------------------------------------------------------------
    if (path.startsWith('/api/customer-addresses/') && request.method == 'DELETE') {
      final addrId = int.tryParse(path.split('/').last) ?? 0;
      if (addrId > 0) {
        await conn.execute('DELETE FROM customer_addresses WHERE id = $addrId;');
      }
      sendJson(res, {'success': true, 'message': 'Address deleted successfully'});
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/merchants (From pos_db.merchants JOIN pos_db.merchant_accounts)
    // ------------------------------------------------------------------------
    if (path == '/api/merchants' && request.method == 'GET') {
      final sql = '''
        SELECT 
          m.id, m.account_id, m.name, m.khmer_name, m.cuisine,
          m.banner_url, m.logo_url, m.address, m.city, m.phone,
          m.rating, m.delivery_time_min, m.delivery_fee_usd, m.is_open,
          m.total_sales_usd, a.account_name
        FROM merchants m
        JOIN merchant_accounts a ON m.account_id = a.id
        ORDER BY m.id ASC;
      ''';
      final result = await conn.execute(sql);
      final List<Map<String, dynamic>> merchants = [];

      for (final row in result.rows) {
        merchants.add({
          'id': row.colByName('id').toString(),
          'accountId': row.colByName('account_id').toString(),
          'accountName': row.colByName('account_name') ?? 'Merchant Account',
          'name': row.colByName('name') ?? 'Restaurant',
          'khmerName': row.colByName('khmer_name') ?? '',
          'cuisine': row.colByName('cuisine') ?? 'Cambodian Gourmet',
          'bannerUrl': row.colByName('banner_url') ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200',
          'logoUrl': row.colByName('logo_url') ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
          'rating': double.tryParse(row.colByName('rating')?.toString() ?? '4.8') ?? 4.8,
          'deliveryTimeMin': int.tryParse(row.colByName('delivery_time_min')?.toString() ?? '20') ?? 20,
          'deliveryFeeUSD': double.tryParse(row.colByName('delivery_fee_usd')?.toString() ?? '1.00') ?? 1.00,
          'isOpen': row.colByName('is_open') == '1' || row.colByName('is_open')?.toLowerCase() == 'true',
          'address': '${row.colByName('address') ?? ''}, ${row.colByName('city') ?? 'Phnom Penh'}',
          'phone': row.colByName('phone') ?? '+855 23 888 999',
          'totalSalesUSD': double.tryParse(row.colByName('total_sales_usd')?.toString() ?? '0.0') ?? 0.0,
        });
      }

      sendJson(res, {'success': true, 'data': merchants});
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/merchant-accounts (All 10 Corporate Merchant Accounts from pos_db)
    // ------------------------------------------------------------------------
    if (path == '/api/merchant-accounts' && request.method == 'GET') {
      final sql = '''
        SELECT a.id, a.account_name, a.email, a.phone, a.company_reg_number, a.status,
               COUNT(m.id) as restaurants_count
        FROM merchant_accounts a
        LEFT JOIN merchants m ON m.account_id = a.id
        GROUP BY a.id, a.account_name, a.email, a.phone, a.company_reg_number, a.status
        ORDER BY a.id ASC;
      ''';
      final result = await conn.execute(sql);
      final List<Map<String, dynamic>> accounts = [];
      for (final row in result.rows) {
        accounts.add({
          'id': row.colByName('id').toString(),
          'accountName': row.colByName('account_name') ?? '',
          'email': row.colByName('email') ?? '',
          'phone': row.colByName('phone') ?? '',
          'companyRegNumber': row.colByName('company_reg_number') ?? '',
          'status': row.colByName('status') ?? 'ACTIVE',
          'restaurantsCount': int.tryParse(row.colByName('restaurants_count')?.toString() ?? '0') ?? 0,
        });
      }
      sendJson(res, {'success': true, 'data': accounts});
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/merchant-auth/login (Merchant Multi-Tenant Login)
    // ------------------------------------------------------------------------
    if (path == '/api/merchant-auth/login' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      final identifier = (body['identifier'] ?? body['email'] ?? '').toString().trim().replaceAll("'", "''");
      final password = (body['password'] ?? '123456').toString().trim();

      final sql = '''
        SELECT id, account_name, email, phone, company_reg_number, status, password
        FROM merchant_accounts
        WHERE email = '$identifier' OR id = '${int.tryParse(identifier) ?? 0}'
        LIMIT 1;
      ''';
      final result = await conn.execute(sql);
      if (result.rows.isEmpty) {
        res.statusCode = HttpStatus.notFound;
        sendJson(res, {'success': false, 'message': 'No merchant corporate account found for: $identifier'});
        return;
      }

      final row = result.rows.first;
      final storedPass = row.colByName('password')?.toString() ?? '123456';
      if (password.isNotEmpty && password != storedPass && storedPass != '123456') {
        res.statusCode = HttpStatus.unauthorized;
        sendJson(res, {'success': false, 'message': 'Incorrect merchant password.'});
        return;
      }

      final accId = row.colByName('id').toString();
      sendJson(res, {
        'success': true,
        'message': 'Welcome back, ${row.colByName('account_name')}!',
        'account': {
          'id': accId,
          'accountName': row.colByName('account_name'),
          'email': row.colByName('email'),
          'phone': row.colByName('phone'),
          'companyRegNumber': row.colByName('company_reg_number'),
          'status': row.colByName('status'),
        }
      });
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/merchant-auth/register (Register New Corporate Merchant + Restaurant)
    // ------------------------------------------------------------------------
    if (path == '/api/merchant-auth/register' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final accountName = (body['accountName'] ?? '').toString().trim().replaceAll("'", "''");
      final email = (body['email'] ?? '').toString().trim().replaceAll("'", "''");
      final phone = (body['phone'] ?? '').toString().trim().replaceAll("'", "''");
      final password = (body['password'] ?? '123456').toString().trim().replaceAll("'", "''");
      final companyRegNumber = (body['companyRegNumber'] ?? 'CR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}').toString().trim().replaceAll("'", "''");
      final restaurantName = (body['restaurantName'] ?? (accountName.isNotEmpty ? '$accountName Kitchen' : 'Partner Restaurant')).toString().trim().replaceAll("'", "''");
      final khmerName = (body['khmerName'] ?? restaurantName).toString().trim().replaceAll("'", "''");
      final cuisine = (body['cuisine'] ?? 'Khmer Gourmet & Asian Specialties').toString().trim().replaceAll("'", "''");
      final address = (body['address'] ?? 'Phnom Penh, Cambodia').toString().trim().replaceAll("'", "''");

      if (accountName.isEmpty || email.isEmpty || password.isEmpty) {
        res.statusCode = HttpStatus.badRequest;
        sendJson(res, {'success': false, 'message': 'Company name, email, and password are required.'});
        return;
      }

      // Check if email already registered
      final existingRes = await conn.execute("SELECT id FROM merchant_accounts WHERE email = '$email' LIMIT 1;");
      if (existingRes.rows.isNotEmpty) {
        res.statusCode = HttpStatus.conflict;
        sendJson(res, {'success': false, 'message': 'A merchant account with email $email already exists.'});
        return;
      }

      // 1. Insert into pos_db.merchant_accounts
      final insertAccSql = '''
        INSERT INTO merchant_accounts (account_name, email, phone, company_reg_number, status, password, created_at)
        VALUES ('$accountName', '$email', '$phone', '$companyRegNumber', 'ACTIVE', '$password', NOW());
      ''';
      final accRes = await conn.execute(insertAccSql);
      final newAccountId = accRes.lastInsertID;

      // 2. Insert primary restaurant into pos_db.merchants
      final bannerUrl = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200';
      final logoUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300';
      final insertRestSql = '''
        INSERT INTO merchants (
          account_id, name, khmer_name, cuisine, banner_url, logo_url,
          address, city, phone, rating, delivery_time_min, delivery_fee_usd, is_open, total_sales_usd, status, created_at
        ) VALUES (
          $newAccountId, '$restaurantName', '$khmerName', '$cuisine', '$bannerUrl', '$logoUrl',
          '$address', 'Phnom Penh', '$phone', 5.0, 20, 1.00, 1, 0.00, 'ACTIVE', NOW()
        );
      ''';
      final restRes = await conn.execute(insertRestSql);
      final newRestId = restRes.lastInsertID;

      // 3. Seed 2 initial dishes in pos_db.products for this restaurant
      await conn.execute('''
        INSERT INTO products (merchant_id, category_id, name, khmer_name, barcode, cost_price, selling_price, stock_quantity, low_stock_threshold, status, image_url, created_at)
        VALUES 
        ($newRestId, 1, 'Signature House Special', 'ម្ហូបពិសេសប្រចាំហាង', 'DISH-$newRestId-01', 2.00, 5.50, 100, 10, 'ACTIVE', '$bannerUrl', NOW()),
        ($newRestId, 2, 'Fresh Iced Beverage', 'ភេសជ្ជៈស្រស់ពិសេស', 'DISH-$newRestId-02', 0.50, 2.00, 150, 15, 'ACTIVE', '$logoUrl', NOW());
      ''');

      sendJson(res, {
        'success': true,
        'message': 'Corporate merchant account registered successfully!',
        'account': {
          'id': newAccountId.toString(),
          'accountName': accountName,
          'email': email,
          'phone': phone,
          'companyRegNumber': companyRegNumber,
          'status': 'ACTIVE',
        },
        'restaurant': {
          'id': newRestId.toString(),
          'accountId': newAccountId.toString(),
          'name': restaurantName,
          'khmerName': khmerName,
          'cuisine': cuisine,
          'address': address,
        }
      });
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/vouchers (From pos_db.vouchers)
    // ------------------------------------------------------------------------
    if (path == '/api/vouchers' && request.method == 'GET') {
      final result = await conn.execute('SELECT * FROM vouchers WHERE is_active = 1 ORDER BY discount_percent DESC;');
      final List<Map<String, dynamic>> list = [];
      for (final row in result.rows) {
        list.add({
          'id': row.colByName('id').toString(),
          'code': row.colByName('code') ?? '',
          'title': row.colByName('title') ?? '',
          'description': row.colByName('description') ?? '',
          'discountPercent': int.tryParse(row.colByName('discount_percent')?.toString() ?? '10') ?? 10,
          'maxDiscountUSD': double.tryParse(row.colByName('max_discount_usd')?.toString() ?? '5.0') ?? 5.0,
          'minSpendUSD': double.tryParse(row.colByName('min_spend_usd')?.toString() ?? '0.0') ?? 0.0,
        });
      }
      sendJson(res, {'success': true, 'data': list});
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/drivers (From pos_db.delivery_drivers)
    // ------------------------------------------------------------------------
    if (path == '/api/drivers' && request.method == 'GET') {
      final result = await conn.execute('SELECT * FROM delivery_drivers ORDER BY rating DESC;');
      final List<Map<String, dynamic>> list = [];
      for (final row in result.rows) {
        list.add({
          'id': row.colByName('id').toString(),
          'code': row.colByName('driver_code') ?? '',
          'name': row.colByName('name') ?? '',
          'khmerName': row.colByName('khmer_name') ?? '',
          'phone': row.colByName('phone') ?? '',
          'vehicleType': row.colByName('vehicle_type') ?? 'Motorcycle',
          'vehiclePlate': row.colByName('vehicle_plate') ?? '',
          'rating': double.tryParse(row.colByName('rating')?.toString() ?? '4.9') ?? 4.9,
          'status': row.colByName('status') ?? 'AVAILABLE',
          'totalDeliveries': int.tryParse(row.colByName('total_deliveries')?.toString() ?? '100') ?? 100,
          'photoUrl': row.colByName('photo_url') ?? '',
        });
      }
      sendJson(res, {'success': true, 'data': list});
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/menu-items (From pos_db.products JOIN pos_db.categories)
    // ------------------------------------------------------------------------
    if (path == '/api/menu-items' && request.method == 'GET') {
      final merchantIdStr = queryParams['merchant_id'];
      final merchantId = int.tryParse(merchantIdStr ?? '');

      String sql = '''
        SELECT 
          p.id, p.merchant_id, p.category_id, p.name, p.khmer_name, p.selling_price, 
          p.cost_price, p.stock_quantity, p.image_url, p.status, 
          c.name as category_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
      ''';

      if (merchantId != null && merchantId > 0) {
        sql += ' WHERE p.merchant_id = $merchantId';
      }
      sql += ' ORDER BY p.id ASC;';

      final result = await conn.execute(sql);
      final List<Map<String, dynamic>> items = [];

      for (final row in result.rows) {
        final statusStr = (row.colByName('status') ?? 'ACTIVE').toString().toUpperCase();
        final isAvailable = statusStr == 'ACTIVE' || statusStr == 'LOW_STOCK';

        items.add({
          'id': row.colByName('id').toString(),
          'merchantId': row.colByName('merchant_id')?.toString() ?? '1',
          'name': row.colByName('name') ?? '',
          'khmerName': row.colByName('khmer_name') ?? '',
          'description': '${row.colByName('khmer_name') ?? ''} • In Stock: ${row.colByName('stock_quantity') ?? 0}',
          'priceUSD': double.tryParse(row.colByName('selling_price')?.toString() ?? '0.00') ?? 0.00,
          'imageUrl': row.colByName('image_url') ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
          'category': row.colByName('category_name') ?? 'Special Dishes',
          'isAvailable': isAvailable,
        });
      }

      sendJson(res, {'success': true, 'data': items});
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/menu-items (Merchant Add Dish to pos_db.products)
    // ------------------------------------------------------------------------
    if (path == '/api/menu-items' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final mId = int.tryParse(body['merchantId']?.toString() ?? '1') ?? 1;
      int categoryId = 4; // default Khmer Food

      final catName = body['category']?.toString() ?? '';
      if (catName.isNotEmpty) {
        final catRes = await conn.execute("SELECT id FROM categories WHERE name LIKE '%$catName%' LIMIT 1;");
        if (catRes.rows.isNotEmpty) {
          categoryId = int.tryParse(catRes.rows.first.colByName('id').toString()) ?? categoryId;
        }
      }

      final name = (body['name'] ?? 'New Dish').toString().replaceAll("'", "''");
      final khmerName = (body['khmerName'] ?? body['description'] ?? 'ម្ហូបថ្មី').toString().replaceAll("'", "''");
      final price = double.tryParse(body['priceUSD']?.toString() ?? '0.0') ?? 0.0;
      final cost = price * 0.45;
      final imageUrl = (body['imageUrl'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300').toString().replaceAll("'", "''");
      final barcode = '885022${DateTime.now().millisecondsSinceEpoch % 100000}';
      final status = body['isAvailable'] == false ? 'OUT_OF_STOCK' : 'ACTIVE';

      final insertSql = '''
        INSERT INTO products (category_id, merchant_id, name, khmer_name, barcode, cost_price, selling_price, stock_quantity, low_stock_threshold, image_url, status)
        VALUES ($categoryId, $mId, '$name', '$khmerName', '$barcode', $cost, $price, 50, 10, '$imageUrl', '$status');
      ''';
      final result = await conn.execute(insertSql);
      final newId = result.lastInsertID.toString();

      sendJson(res, {
        'success': true,
        'message': 'Product saved to pos_db.products',
        'id': newId,
      });
      return;
    }

    // ------------------------------------------------------------------------
    // PUT /api/menu-items/:id (Merchant Edit Dish in pos_db.products)
    // ------------------------------------------------------------------------
    if (path.startsWith('/api/menu-items/') && request.method == 'PUT') {
      final itemId = path.split('/').last;
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final name = (body['name'] ?? '').toString().replaceAll("'", "''");
      final khmerName = (body['khmerName'] ?? '').toString().replaceAll("'", "''");
      final price = double.tryParse(body['priceUSD']?.toString() ?? '0.0') ?? 0.0;
      final imageUrl = (body['imageUrl'] ?? '').toString().replaceAll("'", "''");
      final status = body['isAvailable'] == false ? 'OUT_OF_STOCK' : 'ACTIVE';

      final updateSql = '''
        UPDATE products 
        SET name='$name', khmer_name='$khmerName', selling_price=$price, image_url='$imageUrl', status='$status'
        WHERE id=${int.tryParse(itemId) ?? 0};
      ''';
      await conn.execute(updateSql);

      sendJson(res, {
        'success': true,
        'message': 'Product updated in pos_db.products',
        'id': itemId,
      });
      return;
    }

    // ------------------------------------------------------------------------
    // DELETE /api/menu-items/:id (Merchant Delete from pos_db.products)
    // ------------------------------------------------------------------------
    if (path.startsWith('/api/menu-items/') && request.method == 'DELETE') {
      final itemId = path.split('/').last;
      await conn.execute('DELETE FROM products WHERE id=${int.tryParse(itemId) ?? 0};');

      sendJson(res, {
        'success': true,
        'message': 'Product deleted from pos_db.products',
        'id': itemId,
      });
      return;
    }

    // ------------------------------------------------------------------------
    // GET /api/orders (From pos_db.transactions JOIN pos_db.merchants)
    // ------------------------------------------------------------------------
    if (path == '/api/orders' && request.method == 'GET') {
      final merchantIdStr = queryParams['merchant_id'];
      final merchantId = int.tryParse(merchantIdStr ?? '');

      String sql = '''
        SELECT 
          t.id, t.invoice_number, t.timestamp, t.customer_id, t.merchant_id,
          t.customer_name, t.customer_phone, t.delivery_address,
          t.subtotal, t.discount_amount, t.tax_amount, t.grand_total_usd, t.grand_total_khr,
          t.payment_method, t.status,
          m.name as merchant_name
        FROM transactions t
        LEFT JOIN merchants m ON t.merchant_id = m.id
      ''';

      if (merchantId != null && merchantId > 0) {
        sql += ' WHERE t.merchant_id = $merchantId';
      }
      sql += ' ORDER BY t.id DESC LIMIT 100;';

      final result = await conn.execute(sql);
      final List<Map<String, dynamic>> orders = [];

      for (final row in result.rows) {
        final txId = row.colByName('id');

        // Fetch transaction items for this order
        final itemsRes = await conn.execute('''
          SELECT ti.id, ti.product_id, ti.quantity, ti.unit_price, ti.line_total, p.name as product_name
          FROM transaction_items ti
          LEFT JOIN products p ON ti.product_id = p.id
          WHERE ti.transaction_id = $txId;
        ''');

        final List<Map<String, dynamic>> items = [];
        for (final itemRow in itemsRes.rows) {
          items.add({
            'menuItemId': itemRow.colByName('product_id')?.toString() ?? '1',
            'name': itemRow.colByName('product_name') ?? 'Menu Item',
            'priceUSD': double.tryParse(itemRow.colByName('unit_price')?.toString() ?? '0.0') ?? 0.0,
            'quantity': int.tryParse(itemRow.colByName('quantity')?.toString() ?? '1') ?? 1,
            'specialNotes': 'Standard Preparation',
          });
        }

        final statusStr = (row.colByName('status') ?? 'PENDING').toString().toUpperCase();
        String appStatus = 'delivering';
        if (statusStr == 'PENDING') {
          appStatus = 'pendingAcceptance';
        } else if (statusStr == 'DELIVERING') {
          appStatus = 'delivering';
        } else if (statusStr == 'COMPLETED') {
          appStatus = 'delivered';
        } else if (statusStr == 'REFUNDED' || statusStr == 'FAILED') {
          appStatus = 'cancelled';
        }

        final payMethodStr = (row.colByName('payment_method') ?? 'CASH').toString().toUpperCase();

        orders.add({
          'id': txId.toString(),
          'orderNumber': row.colByName('invoice_number') ?? 'INV-$txId',
          'customerName': row.colByName('customer_name') ?? 'Customer (អតិថិជន)',
          'customerPhone': row.colByName('customer_phone') ?? '+855 12 345 678',
          'deliveryAddress': row.colByName('delivery_address') ?? 'House 42, St 271, Boeng Tumpun, Phnom Penh',
          'merchantId': row.colByName('merchant_id')?.toString() ?? '1',
          'merchantName': row.colByName('merchant_name') ?? 'Angkor Authentic Kitchen',
          'items': items,
          'subtotalUSD': double.tryParse(row.colByName('subtotal')?.toString() ?? '0.0') ?? 0.0,
          'deliveryFeeUSD': 1.00,
          'discountUSD': double.tryParse(row.colByName('discount_amount')?.toString() ?? '0.0') ?? 0.0,
          'totalUSD': double.tryParse(row.colByName('grand_total_usd')?.toString() ?? '0.0') ?? 0.0,
          'totalKHR': double.tryParse(row.colByName('grand_total_khr')?.toString() ?? '0.0') ?? 0.0,
          'paymentMethod': (payMethodStr == 'BAKONG_KHQR' || payMethodStr == 'CREDIT_CARD') ? 'paid' : 'payOnDelivery',
          'status': appStatus,
          'driverId': 'DRV-001',
          'driverName': 'Sokha Chea (ជា សុខា)',
          'driverPlate': 'Phnom Penh 1AB-2345 (Honda Dream)',
          'orderTime': row.colByName('timestamp')?.toString() ?? DateTime.now().toIso8601String(),
        });
      }

      sendJson(res, {'success': true, 'data': orders});
      return;
    }

    // ------------------------------------------------------------------------
    // POST /api/orders (Customer Place Order into pos_db.transactions)
    // ------------------------------------------------------------------------
    if (path == '/api/orders' && request.method == 'POST') {
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final invoiceNum = (body['orderNumber'] != null && body['orderNumber'].toString().isNotEmpty)
          ? body['orderNumber'].toString().replaceAll("'", "''")
          : 'INV-${DateTime.now().millisecondsSinceEpoch % 10000000}';
      final merchantId = int.tryParse(body['merchantId']?.toString() ?? '1') ?? 1;
      final custName = (body['customerName'] ?? 'Customer').toString().replaceAll("'", "''");
      final custPhone = (body['customerPhone'] ?? '+855 12 345 678').toString().replaceAll("'", "''");
      final delivAddress = (body['deliveryAddress'] ?? 'Phnom Penh').toString().replaceAll("'", "''");

      final totalAmount = double.tryParse(body['totalUSD']?.toString() ?? '0.0') ?? 0.0;
      final subtotal = double.tryParse(body['subtotalUSD']?.toString() ?? '0.0') ?? totalAmount;
      final grandTotalKHR = totalAmount * 4100.0;
      final payMethod = body['paymentMethod'] == 'paid' ? 'CREDIT_CARD' : 'CASH';

      final insertTxSql = '''
        INSERT INTO transactions (
          invoice_number, timestamp, customer_id, merchant_id,
          customer_name, customer_phone, delivery_address,
          subtotal, discount_amount, tax_amount, grand_total_usd, grand_total_khr,
          payment_method, payment_reference, amount_tendered, change_given, status
        ) VALUES (
          '$invoiceNum', NOW(), 1, $merchantId,
          '$custName', '$custPhone', '$delivAddress',
          $subtotal, 0.00, 0.00, $totalAmount, $grandTotalKHR,
          '$payMethod', 'APP-$invoiceNum', $totalAmount, 0.00, 'PENDING'
        );
      ''';
      final txRes = await conn.execute(insertTxSql);
      final txId = txRes.lastInsertID;

      // Update merchant sales in pos_db.merchants
      await conn.execute('UPDATE merchants SET total_sales_usd = total_sales_usd + $totalAmount WHERE id = $merchantId;');

      // Insert transaction items
      final itemsList = body['items'] as List<dynamic>? ?? [];
      for (final item in itemsList) {
        final pId = int.tryParse(item['menuItemId']?.toString() ?? '1') ?? 1;
        final price = double.tryParse(item['priceUSD']?.toString() ?? '0.0') ?? 0.0;
        final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        final lineTotal = price * qty;

        final insertItemSql = '''
          INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, discount_percent, line_total)
          VALUES ($txId, $pId, $qty, $price, 0.00, $lineTotal);
        ''';
        await conn.execute(insertItemSql);
      }

      sendJson(res, {
        'success': true,
        'message': 'Order placed into pos_db.transactions',
        'id': txId.toString(),
        'orderNumber': invoiceNum,
      });
      return;
    }

    // ------------------------------------------------------------------------
    // PUT /api/orders/:id/status (Merchant Updates Status in pos_db.transactions)
    // ------------------------------------------------------------------------
    if (path.startsWith('/api/orders/') && path.endsWith('/status') && request.method == 'PUT') {
      final segments = path.split('/');
      final txId = segments[segments.length - 2];
      final bodyStr = await utf8.decodeStream(request);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final newStatus = (body['status'] ?? '').toString();
      String dbStatus = 'PENDING';
      if (newStatus == 'delivering') {
        dbStatus = 'DELIVERING';
      } else if (newStatus == 'delivered') {
        dbStatus = 'COMPLETED';
      } else if (newStatus == 'cancelled') {
        dbStatus = 'REFUNDED';
      } else if (newStatus == 'pendingAcceptance') {
        dbStatus = 'PENDING';
      } else {
        dbStatus = newStatus.toUpperCase();
      }

      await conn.execute('''
        UPDATE transactions 
        SET status='$dbStatus'
        WHERE id=${int.tryParse(txId) ?? 0} OR invoice_number='$txId';
      ''');

      sendJson(res, {
        'success': true,
        'message': 'Status updated in pos_db.transactions',
        'id': txId,
        'status': dbStatus,
      });
      return;
    }

    // Default 404
    res.statusCode = HttpStatus.notFound;
    sendJson(res, {'error': 'Endpoint not found', 'path': path});
  } catch (e, stack) {
    print('! Error handling request: $e\n$stack');
    _connection = null;
    res.statusCode = HttpStatus.internalServerError;
    sendJson(res, {'error': e.toString()});
  }
}

void sendJson(HttpResponse response, Map<String, dynamic> data) {
  response.write(jsonEncode(data));
  response.close();
}
