const { MongoClient } = require('mongodb');

const uri = 'mongodb+srv://praveennaidu297:$APLSP2utmKd$7.@cluster0.qddnp.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const client = new MongoClient(uri);

async function testConnection() {
    try {
        await client.connect();
        console.log('Connected successfully to MongoDB');
    } catch (error) {
        console.error('Connection error:', error.message);
    } finally {
        await client.close();
    }
}

testConnection();

/*const mongoose = require('mongoose');

const mondbUrl="mongodb+srv://praveennaidu297:$APLSP2utmKd$7.@cluster0.qddnp.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

const connectDb=()=>{
    return mongoose.connect(mondbUrl)
}

module.exports={connectDb};
*/