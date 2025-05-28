module.exports = {
  apps: [{
    name: 'lab-management',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env_production: {
      NODE_ENV: 'production',
      PORT: 3003,
      DB_HOST: process.env.DB_HOST,
      DB_USER: process.env.DB_USER,
      DB_PASSWORD: process.env.DB_PASSWORD,
      DB_NAME: 'lab_management',
      DB_SSL: 'true',
      ALLOWED_ORIGINS: 'https://yourdomain.com',
      JWT_SECRET: process.env.JWT_SECRET,
      SESSION_SECRET: process.env.SESSION_SECRET,
      COOKIE_SECRET: process.env.COOKIE_SECRET,
      LOG_LEVEL: 'info'
    }
  }]
}; 