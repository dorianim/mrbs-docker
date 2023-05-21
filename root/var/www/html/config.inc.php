<?php

/*******************
 * Database settings
 ******************/
// Which database system: "pgsql"=PostgreSQL, "mysql"=MySQL
$dbsys = $_ENV['MRBS_DB_SYSTEM'];
// Hostname of database server. For pgsql, can use "" instead of localhost
// to use Unix Domain Sockets instead of TCP/IP. For mysql "localhost"
// tells the system to use Unix Domain Sockets, and $db_port will be ignored;
// if you want to force TCP connection you can use "127.0.0.1".
$db_host = $_ENV['MRBS_DB_HOST'] ?? $_ENV['DB_HOST'];
// If you need to use a non standard port for the database connection you
// can uncomment the following line and specify the port number
// $db_port = 1234;
// Database name:
$db_database = $_ENV['MRBS_DB_DATABASE'] ?? $_ENV['DB_DATABASE'];
// Schema name.  This only applies to PostgreSQL and is only necessary if you have more
// than one schema in your database and also you are using the same MRBS table names in
// multiple schemas.
//$db_schema = "public";
// Database login user name:
$db_login = $_ENV['MRBS_DB_USER'] ?? $_ENV['DB_USER'];
// Database login password:
$db_password = $_ENV['MRBS_DB_PASSWORD']  ?? $_ENV['DB_PASS'];
// Prefix for table names.  This will allow multiple installations where only
// one database is available
$db_tbl_prefix = $_ENV['MRBS_DB_TBL_PREFIX'] ?? "mrbs_";
// Set $db_persist to TRUE to use PHP persistent (pooled) database connections.  Note
// that persistent connections are not recommended unless your system suffers significant
// performance problems without them.   They can cause problems with transactions and
// locks (see http://php.net/manual/en/features.persistent-connections.php) and although
// MRBS tries to avoid those problems, it is generally better not to use persistent
// connections if you can.
$db_persist = false;

// default to modern theme
$theme = "modern";
$disable_menu_items_for_non_admins = ["rooms", "user_list"];

require "/config/www/config.inc.php";
