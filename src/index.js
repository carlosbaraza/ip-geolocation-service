const express = require('express');
const app = express();
const port = 3000;
const ipRexex = /(\d{1,3}\.){3}\d{1,3}/;

const { Client } = require('pg');
const client = new Client({
    user: 'postgres',
    database: 'ip2location_database',
    password: '345',
});
client.connect();
// await client.end();

app.get('/', async (req, res) => {
    const {ip} = req.query;
    if (!ip) {
        res.status(400);
        return res.send(`The "ip" querystring is mandatory`);
    }
    if (!ip.match(ipRexex)) {
        res.status(400);
        return res.send(`The "ip" querystring does not have the standard format X.X.X.X`);
    }
    const parsedIp = ip.match(ipRexex)[0]
    const response = await client.query(`SELECT * FROM ip2location_database WHERE inet_to_bigint($1) <= ip_to LIMIT 1;`, [parsedIp]);
    
    res.json(response.rows[0]);
});

app.listen(port, () => console.log(`IP Geolocation service listening on port ${port}!`));