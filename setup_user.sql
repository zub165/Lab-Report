CREATE USER IF NOT EXISTS 'labuser'@'localhost' IDENTIFIED BY 'Bismilah786$';
GRANT ALL PRIVILEGES ON lab_management.* TO 'labuser'@'localhost';
FLUSH PRIVILEGES; 