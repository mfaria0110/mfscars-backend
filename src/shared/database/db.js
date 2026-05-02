const { Pool } = require('pg')

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'mfs_cars_db',
  password: 'postgres123',
  port: 5432,

  /* 🔥 CONTROLE DE CONEXÕES (ESSENCIAL) */
  max: 20, // máximo de conexões simultâneas
  idleTimeoutMillis: 30000, // fecha conexões ociosas
  connectionTimeoutMillis: 5000
})

/* 🔥 LOG OPCIONAL (AJUDA MUITO DEBUG) */
pool.on('connect', () => {
  console.log('🔌 Nova conexão com o banco')
})

pool.on('error', (err) => {
  console.error('💥 ERRO NO POOL:', err)
})

module.exports = pool