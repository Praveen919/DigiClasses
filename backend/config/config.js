// config/config.js

const mongoose = require('mongoose');
const Grid = require('gridfs-stream');
const { MONGODB_URI } = process.env;

mongoose.connect(MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Connected to MongoDB with Mongoose');
}).catch((error) => {
    console.error('Failed to connect to MongoDB', error);
    process.exit(1);
});

// Init gfs
let gfs;
const conn = mongoose.connection;
conn.once('open', () => {
    gfs = Grid(conn.db, mongoose.mongo);
    gfs.collection('uploads');
});

module.exports = gfs;
