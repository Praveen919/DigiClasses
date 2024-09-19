const axios = require('axios');

// Replace the express part with an axios post request
axios.post('http://192.168.0.104:3000/login', {
  email: 'pn21@gmail.com',
  password: 'praveen21'
})
.then(response => {
  console.log('Response:', response.data);
})
.catch(error => {
  console.error('Error:', error.response ? error.response.data : error.message);
});
