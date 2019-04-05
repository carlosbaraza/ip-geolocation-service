const express = require('express');
const { Client } = require('pg');

const IP_REGEX = /(\d{1,3}\.){3}\d{1,3}/;
const PORT = 3000;

const client = new Client({
    user: 'postgres',
    database: 'ip2location_database',
    password: '345',
});
client.connect();

const app = express();

app.get('/', async (req, res) => {
    const {ip} = req.query;
    
    if (!ip) {
        res.status(400);
        return res.send(`The "ip" querystring is mandatory`);
    }
    
    if (!ip.match(IP_REGEX)) {
        res.status(400);
        return res.send(`The "ip" querystring does not have the standard format X.X.X.X`);
    }
    
    try {
        const parsedIp = ip.match(IP_REGEX)[0]
        const response = await client.query(`SELECT * FROM ip2location_database WHERE inet_to_bigint($1) <= ip_to LIMIT 1;`, [parsedIp]);
        res.json(response.rows[0]);
    } catch(error) {
        res.status(500);
        res.send("Internal server error")
    }
});

app.listen(
    PORT,
    () => console.log(`IP Geolocation service listening on port ${PORT}!`)
);