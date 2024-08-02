const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();
const port = 3000;

// Database configuration
const pool = new Pool({
  host: '34.71.87.187',
  port: 5432,
  database: 'datagovernance',
  user: 'postgres',
  password: 'India@5555',
});

// Middleware to parse JSON bodies and handle CORS
app.use(bodyParser.json());
app.use(cors());

// API endpoint for user login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Check if the user is an admin
    if (email === 'admin@gmail.com' && password === 'admin@123') {
      res.json({ isAdmin: true, isUser: true });
      return;
    }

    // Check user credentials
    const userResult = await pool.query(
      'SELECT * FROM public.master_demo_user WHERE email = $1 AND password = $2',
      [email, password]
    );

    if (userResult.rows.length > 0) {
      res.json({ isAdmin: false, isUser: true, userData: userResult.rows[0] });
      return;
    }

    // Check mentor credentials
    const mentorResult = await pool.query(
      'SELECT * FROM public.advisor_details WHERE email = $1 AND password = $2',
      [email, password]
    );

    if (mentorResult.rows.length > 0) {
      res.json({ isAdmin: false, isUser: false, mentorData: mentorResult.rows[0] });
      return;
    }

    // If no user or mentor found
    res.status(401).json({ error: 'Invalid username or password' });
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/register', async (req, res) => {
  const { name, password, email, number,image_url } = req.body;

  try {
    // Check if the email already exists
    const emailExists = await checkEmailExists(email);
    if (emailExists) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Insert the new user into the database
    const result = await pool.query(
      'INSERT INTO public.master_demo_user(name, password, email, number,image_url) VALUES ($1, $2, $3, $4, $5)',
      [name, password, email, number, image_url]
    );

    res.status(201).json({ success: 'User registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Check email exists function
async function checkEmailExists(email) {
  try {
    const result = await pool.query(
      'SELECT COUNT(*) FROM public.master_demo_user WHERE email = $1',
      [email]
    );

    // Ensure the result is properly cast to an integer
    const count = parseInt(result.rows[0].count, 10);
    return count > 0;
  } catch (error) {
    console.error(error);
    return false;
  }
}


app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
