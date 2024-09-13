const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: 5432, // default Postgres port
    database: process.env.DATABASE
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};