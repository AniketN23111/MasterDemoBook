const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();
const { format } = require('date-fns');
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
//API endpoint for user Register
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
app.post('/api/fetchUserCredentials', (req, res) => {
    const { email, password } = req.body;

    exec(`dart run fetchUserCredentials.dart ${email} ${password}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error}`);
            return res.status(500).json({ success: false });
        }
        res.json({ success: stdout.trim() === 'true' });
    });
});

// Endpoint for fetching mentor credentials
app.post('/api/fetchMentorCredentials', (req, res) => {
    const { email, password } = req.body;

    exec(`dart run fetchMentorCredentials.dart ${email} ${password}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error}`);
            return res.status(500).json({ success: false });
        }
        res.json({ success: stdout.trim() === 'true' });
    });
});

// Endpoint for fetching user data
app.post('/api/fetchUserData', (req, res) => {
    const { email } = req.body;

    exec(`dart run fetchUserData.dart ${email}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error}`);
            return res.status(500).json([]);
        }
        res.json(JSON.parse(stdout));
    });
});

// Endpoint for fetching mentor data
app.post('/api/fetchMentorData', (req, res) => {
    const { email } = req.body;

    exec(`dart run fetchMentorData.dart ${email}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error}`);
            return res.status(500).json([]);
        }
        res.json(JSON.parse(stdout));
    });
});

app.post('/registerService', async (req, res) => {
  const { service, subService, imageUrl } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO public.service_master(service, sub_service, icon_url) VALUES ($1, $2, $3)',
      [service, subService, imageUrl]
    );
    res.status(200).json({ success: true, message: 'Service registered successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Error registering service', error: err });
  }
});

// Register Program Initializer
app.post('/registerProgramInitializer', async (req, res) => {
  const {
    programName,
    programDescription,
    organizationName,
    imageUrl,
    coordinatorName,
    coordinatorEmail,
    coordinatorNumber,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO public.program_initializer(program_name, program_description, organization_name, icon_url,
        coordinator_name, coordinator_email, coordinator_number)
        VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [programName, programDescription, organizationName, imageUrl, coordinatorName, coordinatorEmail, coordinatorNumber]
    );
    res.status(200).json({ success: true, message: 'Program initializer registered successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Error registering program initializer', error: err });
  }
});

// Route to get all mentor details
app.get('/mentor/details', async (req, res) => {
  try {
    const results = await pool.query('SELECT * FROM public.advisor_details');
    res.json(results.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get all admin services
app.get('/admin/services', async (req, res) => {
  try {
    const results = await pool.query('SELECT * FROM public.service_master');
    res.json(results.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//Register Mentor
app.post('/registerMentor', async (req, res) => {
  const client = await pool.connect();
  try {
    const {
      name,
      address,
      mobile,
      email,
      pincode,
      country,
      state,
      city,
      area,
      license,
      workingDays,
      timeslot,
      imageUrl,
      company_name,
      designation,
      gender,
      date_of_birth,
      password,
      selectedServices,
    } = req.body;

    // Start a transaction
    await client.query('BEGIN');

    // Insert into advisor_details table and get the generated advisor_id
    const result = await client.query(`
      INSERT INTO public.advisor_details (
        name, address, mobile, email, pincode, country, state, city, area, license, working_days, timeslot, image_url, company_name, designation, gender, date_of_birth, password
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
      ) RETURNING advisor_id;
    `, [
      name, address, mobile, email, pincode, country, state, city, area, license, workingDays, timeslot, imageUrl, company_name, designation, gender, date_of_birth, password
    ]);

    const advisorID = result.rows[0].advisor_id;

    // Insert service details into advisor_service_details table
    for (const service of selectedServices) {
      const parts = service.split(' - ');

      if (parts.length !== 5) {
        continue; // Skip this invalid service string
      }

      const mainService = parts[0].split(': ').pop().trim();
      const subService = parts[1].split(': ').pop().trim();
      const rate = parts[2].split(': ').pop().trim();
      const quantity = parts[3].split(': ').pop().trim();
      const unit = parts[4].split(': ').pop().trim();

      await client.query(`
        INSERT INTO public.advisor_service_details (
          advisor_id, main_service, sub_service, rate, quantity, unit_of_measurement
        ) VALUES (
          $1, $2, $3, $4, $5, $6
        );
      `, [advisorID, mainService, subService, rate, quantity, unit]);
    }

    // Commit the transaction
    await client.query('COMMIT');

    res.status(200).json({ message: 'Details registered successfully' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Failed to register mentor details' });
  } finally {
    client.release();
  }
});
// Route to get all mentor services
app.get('/mentor/services', async (req, res) => {
  try {
    const results = await pool.query('SELECT * FROM public.advisor_service_details');
    res.json(results.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get user details by email and password
app.post('/user/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const results = await pool.query(
      'SELECT * FROM master_demo_user WHERE email = $1 AND password = $2',
      [email, password]
    );
    if (results.rows.length > 0) {
      res.json(results.rows[0]);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get mentor details by email and password
app.post('/mentor/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const results = await pool.query(
      'SELECT * FROM advisor_details WHERE email = $1 AND password = $2',
      [email, password]
    );
    if (results.rows.length > 0) {
      res.json(results.rows[0]);
    } else {
      res.status(404).json({ error: 'Mentor not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get user appointments by user ID

app.get('/user/appointments/:userID', async (req, res) => {
  const userID = req.params.userID;
  try {
    const results = await pool.query('SELECT appointment_id, date, "time", advisor_id, main_service, sub_service, user_id FROM appointments WHERE user_id = $1', [userID]);

    // Format the date to the desired format
    const formattedResults = results.rows.map(row => ({
      ...row,
      date: format(new Date(row.date), 'yyyy/MM/dd')  // Adjust format as needed
    }));

    res.json(formattedResults);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get user details by user ID
app.get('/user/:userID', async (req, res) => {
  const userID = req.params.userID;
  try {
    const results = await pool.query('SELECT * FROM master_demo_user WHERE user_id = $1', [userID]);
    if (results.rows.length > 0) {
      res.json(results.rows[0]);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get mentor appointments by mentor ID
app.get('/mentor/appointments/:advisorID', async (req, res) => {
  const advisorID = req.params.advisorID;
  try {
    const results = await pool.query('SELECT * FROM appointments WHERE advisor_id = $1', [advisorID]);
   // Format the date to the desired format
       const formattedResults = results.rows.map(row => ({
         ...row,
         date: format(new Date(row.date), 'yyyy/MM/dd')  // Adjust format as needed
       }));

       res.json(formattedResults);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to insert a new mentor meeting
app.post('/mentor/meetings', async (req, res) => {
  const {
    userId, advisorId, title, meetingDate, startTime, endTime,
    location, eventDetails, description, meetingLink, appointmentId
  } = req.body;

  try {
    await pool.query(
      `INSERT INTO mentor_meetings (user_id, advisor_id, title, meeting_date, start_time, end_time,
        location, event_details, description, meeting_link, appointment_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [userId, advisorId, title, meetingDate, startTime, endTime,
        location, eventDetails, description, meetingLink, appointmentId]
    );
    res.status(201).json({ message: 'Meeting inserted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get user meeting details by date and time
app.post('/user/meeting', async (req, res) => {
  const { date, startTime } = req.body;
  try {
    const results = await pool.query(
      'SELECT * FROM mentor_meetings WHERE meeting_date = $1 AND start_time = $2',
      [date, startTime]
    );
    if (results.rows.length > 0) {
      res.json(results.rows[0]);
    } else {
      res.status(404).json({ error: 'Meeting not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Function to get user name by user ID
app.get('/getUserName/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query('SELECT name AS user_name FROM master_demo_user WHERE user_id = $1', [userId]);
    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    console.error('Error retrieving user name', err.stack);
    res.status(500).json({ error: 'Failed to retrieve user name' });
  }
});

// Function to get advisor name by advisor ID
app.get('/getAdvisorName/:advisorId', async (req, res) => {
  const advisorId = parseInt(req.params.advisorId, 10); // Extract and parse advisorId
  try {
    const result = await pool.query('SELECT name FROM advisor_details WHERE advisor_id = $1', [advisorId]);
    if (result.rows.length > 0) {
      res.json({ advisor_name: result.rows[0].name }); // Send as JSON with key
    } else {
      res.json({ advisor_name: 'Unknown Advisor' }); // Send as JSON with key
    }
  } catch (err) {
    console.error('Error retrieving advisor name', err.stack);
    res.status(500).json({ error: 'Failed to retrieve advisor name' });
  }
});

// Function to insert progress tracking
app.post('/insertProgressTracking', async (req, res) => {
  const {
    advisorId, advisorName, userId, userName, date, goalType, goal, actionSteps, timeline,
    progressDate, progressMade, effectivenessDate, outcome, nextSteps, meetingDate,
    agenda, additionalNotes, appointmentId
  } = req.body;

  try {
    await pool.query(`
      INSERT INTO progress_tracking (
        advisor_id, advisor_name, user_id, user_name, date, goal_type, goal,
        action_steps, timeline, progress_date, progress_made,
        effectiveness_date, outcome, next_steps, meeting_date, agenda, additional_notes, appointment_id
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
    `, [advisorId, advisorName, userId, userName, date, goalType, goal, actionSteps, timeline,
      progressDate, progressMade, effectivenessDate, outcome, nextSteps, meetingDate,
      agenda, additionalNotes, appointmentId]);

    res.status(200).json({ message: 'Progress tracking inserted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Function to get appointment ID based on date, time, advisor ID, main service, sub service, and user ID
// In server.js

app.get('/get-appointment-id', async (req, res) => {
  const { date, time, advisorId, mainService, subService, userId } = req.query;

  try {
    // Construct SQL query to retrieve appointment ID
    const query = `
      SELECT appointment_id
      FROM appointments
      WHERE user_id = $1
        AND date = $2
        AND sub_service = $3
        AND main_service = $4
        AND advisor_id = $5
        AND time = $6
    `;
    const values = [userId, date, subService, mainService, advisorId, time];

    // Execute the query
    const result = await pool.query(query, values);

    // Send the appointment ID if found, otherwise send null
    if (result.rows.length > 0) {
      res.json({ appointment_id: parseInt(result.rows[0].appointment_id, 10) });
    } else {
      res.json({ appointment_id: null });
    }
  } catch (err) {
    console.error('Error retrieving appointment ID:', err.message);
    res.status(500).json({ error: 'Failed to retrieve appointment ID' });
  }
});

// Function to get details from appointments
app.post('/getDetailsFromAppointment', async (req, res) => {
  const { advisorId, userId, appointmentId } = req.body;
  try {
    const result = await pool.query(`
      SELECT * FROM appointments
      WHERE advisor_id = $1 AND user_id = $2 AND appointment_id = $3
    `, [advisorId, userId, appointmentId]);

    res.json(result.rows.length > 0 ? result.rows[0] : null);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Function to get the list of appointments for an advisor
app.get('/getAdvisorAppointments/:advisorId', async (req, res) => {
  const advisorId = parseInt(req.params.advisorId);
  try {
    const result = await pool.query('SELECT * FROM appointments WHERE advisor_id = $1', [advisorId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Function to get the list of appointments for a user
app.get('/getUserAppointments/:userId', async (req, res) => {
  const userId = parseInt(req.params.userId);
  try {
    const result = await pool.query('SELECT * FROM appointments WHERE user_id = $1', [userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get progress tracking by appointment ID
app.get('/progress-tracking/:appointmentID', async (req, res) => {
  const { appointmentID } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM progress_tracking WHERE appointment_id = $1',
      [appointmentID]
    );

    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ error: 'Progress tracking not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get Progress Details goal types
app.post('/getProgressDetailsByGoalType', async (req, res) => {
  const { userId, advisorId, goalType } = req.body;

  try {
    const results = await pool.query(
      'SELECT * FROM progress_tracking WHERE user_id = $1 AND advisor_id = $2 AND goal_type = $3',
      [userId, advisorId, goalType]
    );

    const progressList = results.rows.map(row => ({
      advisor_id: row.advisor_id,
      advisor_name: row.advisor_name,
      user_id: row.user_id,
      user_name: row.user_name,
      date: row.date,
      goal_type: row.goal_type,
      goal: row.goal,
      action_steps: row.action_steps,
      timeline: row.timeline,
      progress_date: row.progress_date,
      progress_made: row.progress_made,
      effectiveness_date: row.effectiveness_date,
      outcome: row.outcome,
      next_steps: row.next_steps,
      meeting_date: row.meeting_date,
      agenda: row.agenda,
      additional_notes: row.additional_notes,
      appointment_id: row.appointment_id,
      progress_status: row.progress_status,
    }));

    res.json(progressList);
  } catch (error) {
    console.error('Error fetching progress details:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Get distinct goal types
app.post('/getDistinctGoalTypes', async (req, res) => {
  const { userId, advisorId } = req.body;

  try {
    const results = await pool.query(
      'SELECT DISTINCT goal_type FROM progress_tracking WHERE user_id = $1 AND advisor_id = $2',
      [userId, advisorId]
    );

    const goalTypes = results.rows.map(row => row.goal_type);

    res.json(goalTypes);
  } catch (error) {
    console.error('Error fetching distinct goal types:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Get progress details by goal type
app.get('/progress-details/:userId/:advisorId/:goalType', async (req, res) => {
  const { userId, advisorId, goalType } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM progress_tracking WHERE user_id = $1 AND advisor_id = $2 AND goal_type = $3',
      [userId, advisorId, goalType]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Update progress tracking
app.put('/progress-tracking/update', async (req, res) => {
  const progressTracking = req.body;

  try {
    await pool.query(
      `UPDATE progress_tracking
       SET advisor_name = $1, user_name = $2, date = $3, goal_type = $4, goal = $5,
           action_steps = $6, timeline = $7, progress_date = $8, progress_made = $9,
           effectiveness_date = $10, outcome = $11, next_steps = $12, meeting_date = $13,
           agenda = $14, additional_notes = $15, progress_status = $16
       WHERE appointment_id = $17`,
      [
        progressTracking.advisorName,
        progressTracking.userName,
        progressTracking.date,
        progressTracking.goalType,
        progressTracking.goal,
        progressTracking.actionSteps,
        progressTracking.timeline,
        progressTracking.progressDate,
        progressTracking.progressMade,
        progressTracking.effectivenessDate,
        progressTracking.outcome,
        progressTracking.nextSteps,
        progressTracking.meetingDate,
        progressTracking.agenda,
        progressTracking.additionalNotes,
        progressTracking.progressStatus,
        progressTracking.appointmentId,
      ]
    );

    res.json({ status: 'Success' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get program initializer by ID
app.get('/program-initializer/:programId', async (req, res) => {
  const { programId } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM program_initializer WHERE program_id = $1',
      [programId]
    );

    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ error: 'Program initializer not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get program initializer names
app.get('/program-initializer-names', async (req, res) => {
  try {
    const result = await pool.query('SELECT program_name FROM program_initializer');

    res.json(result.rows.map(row => row.program_name));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get mentor meeting counts
 app.get('/getMentorMeetingCounts/:year', async (req, res) => {
   const year = parseInt(req.params.year, 10);

   if (isNaN(year)) {
     return res.status(400).json({ error: 'Invalid year parameter' });
   }

   try {
     const result = await pool.query(
       `SELECT advisor_id, EXTRACT(MONTH FROM date) as month, COUNT(*) AS meeting_count
        FROM appointments WHERE EXTRACT(YEAR FROM date) = $1 GROUP BY advisor_id, EXTRACT(MONTH FROM date)`,
       [year]
     );

     const data = {};

     for (const row of result.rows) {
       const advisorId = row.advisor_id;
       const month = parseInt(row.month, 10); // Ensure month is an integer
       const meetingCount = parseInt(row.meeting_count, 10); // Ensure meeting_count is an integer

       const mentorName = await getMentorName(advisorId); // Await the async function

       const uniqueKey = `${mentorName} (ID: ${advisorId})`;

       if (!data[uniqueKey]) {
         data[uniqueKey] = {};
       }

       data[uniqueKey][month] = meetingCount;
     }

     res.json(data);
   } catch (err) {
     console.error(err);
     res.status(500).json({ error: 'Database error' });
   }
 });

// Get mentee meeting counts
app.get('/getMenteeMeetingCounts/:year', async (req, res) => {
  const year = parseInt(req.params.year, 10);

     if (isNaN(year)) {
       return res.status(400).json({ error: 'Invalid year parameter' });
     }

  try {
    const result = await pool.query(
      `SELECT user_id, EXTRACT(MONTH FROM date) AS month, COUNT(*) AS count
       FROM appointments WHERE EXTRACT(YEAR FROM date) = $1 GROUP BY user_id, EXTRACT(MONTH FROM date)`,
      [year]
    );
    const data = {};
    for (const row of result.rows) {
      const userId = row.user_id;
      const month = parseInt(row.month, 10);
      const count = parseInt(row.count, 10);

      const menteeName = await getMenteeName(userId);

      const uniqueKey = `${menteeName} (ID: ${userId})`;

      if (!data[uniqueKey]) {
        data[uniqueKey] = {};
      }

      data[uniqueKey][month] = count;
    }

    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get appointments for a specific month and year
app.get('/appointments/:month/:year', async (req, res) => {
  const { month, year } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM appointments WHERE EXTRACT(MONTH FROM date) = $1 AND EXTRACT(YEAR FROM date) = $2',
      [month, year]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Endpoint to fetch booked time slots for a specific mentor (advisor)
app.get('/booked-time-slots/:advisorId', async (req, res) => {
  const { advisorId } = req.params;

  try {
    const query = 'SELECT date, time FROM appointments WHERE advisor_id = $1';
    const values = [advisorId];

    const result = await pool.query(query, values);

    const bookedTimeSlots = result.rows.map(row => ({
      date: row.date.toISOString().split('T')[0],  // Format the date as YYYY-MM-DD
      time: row.time
    }));

    res.status(200).json(bookedTimeSlots);
  } catch (err) {
    console.error('Error fetching booked time slots', err.stack);
    res.status(500).json({ error: 'Failed to fetch booked time slots' });
  }
});

// Helper function to get mentor name by advisorId
async function getMentorName(advisorId) {
  const result = await pool.query(
    'SELECT name FROM advisor_details WHERE advisor_id = $1',
    [advisorId]
  );

  if (result.rows.length > 0) {
    return result.rows[0].name;
  } else {
    return 'Unknown';
  }
}

// Helper function to get mentee name by userId
async function getMenteeName(userId) {
  const result = await pool.query(
    'SELECT name FROM master_demo_user WHERE user_id = $1',
    [userId]
  );

  if (result.rows.length > 0) {
    return result.rows[0].name;
  } else {
    return 'Unknown';
  }
}

// Endpoint to confirm an appointment
app.post('/confirm-appointment', async (req, res) => {
  const { advisorId, userId, date, timeSlot, services } = req.body;

  try {
    // Insert each service as a separate appointment
    for (let service of services) {
      const query = `
        INSERT INTO appointments (advisor_id, user_id, date, time, main_service, sub_service)
        VALUES ($1, $2, $3, $4, $5, $6)
      `;
      await pool.query(query, [
        advisorId,
        userId,
        date,
        timeSlot,
        service.mainService,
        service.subService,
      ]);
    }
    res.status(200).json({ message: 'Appointment confirmed successfully' });
  } catch (err) {
    console.error('Error confirming appointment', err.stack);
    res.status(500).json({ error: 'Failed to confirm appointment' });
  }
});

app.post('/save-meeting-details', async (req, res) => {
  const {
    advisorId,
    advisorName,
    userId,
    userName,
    date,
    goal,
    mainServices,
    subServices,
    startTime,
    endTime,
    agenda,
    additionalNotes,
    appointmentId,
    location,
    description,
    meetingLink
  } = req.body;

  try {
    // Convert times to 24-hour format
    const startTime24 = convertTo24HourFormat(startTime);
    const endTime24 = convertTo24HourFormat(endTime);

    await pool.query('BEGIN'); // Start a transaction

    for (let i = 0; i < mainServices.length; i++) {
      const query1 = `
        INSERT INTO progress_tracking
        (advisor_id, advisor_name, user_id, user_name, date, goal_type, goal, action_steps, timeline, progress_date, progress_made, effectiveness_date, outcome, next_steps, meeting_date, agenda, additional_notes, appointment_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      `;
      await pool.query(query1, [
        advisorId,
        advisorName,
        userId,
        userName,
        date,
        'Meeting',
        goal,
        `${mainServices[i]} - ${subServices[i]}`,
        `${startTime} - ${endTime}`,
        date,
        '',
        date,
        '',
        '',
        date,
        agenda,
        additionalNotes,
        appointmentId,
      ]);
    }

    for (let i = 0; i < mainServices.length; i++) {
      const query2 = `
        INSERT INTO mentor_meetings
        (user_id, advisor_id, title, meeting_date, start_time, end_time, location, event_details, description, meeting_link, appointment_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      `;
      await pool.query(query2, [
        userId,
        advisorId,
        goal,
        date,
        startTime24,
        endTime24,
        location,
        `${mainServices[i]} - ${subServices[i]}`,
        description,
        meetingLink,
        appointmentId,
      ]);
    }

    await pool.query('COMMIT'); // Commit the transaction
    res.status(200).json({ message: 'Meeting details saved successfully' });
  } catch (err) {
    await pool.query('ROLLBACK'); // Rollback the transaction on error
    console.error('Error saving meeting details:', err.message);
    res.status(500).json({ error: 'Failed to save meeting details', details: err.message });
  }
});

app.post('/insert-mentor-meeting', async (req, res) => {
  const {
    userId,
    advisorId,
    title,
    meetingDate,
    startTime,
    endTime,
    location,
    eventDetails,
    description,
    meetingLink,
    appointmentId,
  } = req.body;

  try {
    const query = `
      INSERT INTO mentor_meetings
      (user_id, advisor_id, title, meeting_date, start_time, end_time, location, event_details, description, meeting_link, appointment_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `;

    const values = [
      userId,
      advisorId,
      title,
      meetingDate,
      startTime,
      endTime,
      location,
      eventDetails,
      description,
      meetingLink,
      appointmentId,
    ];

    await pool.query(query, values);
    res.status(200).json({ message: 'Mentor meeting inserted successfully' });
  } catch (err) {
    console.error('Error inserting mentor meeting:', err);
    res.status(500).json({ error: 'Failed to insert mentor meeting', details: err.message });
  }
});

// Route to insert progress tracking details
app.post('/insert-progress-tracking', async (req, res) => {
  const {
    advisorId,
    advisorName,
    userId,
    userName,
    date,
    goalType,
    goal,
    actionSteps,
    timeline,
    progressDate,
    progressMade,
    effectivenessDate,
    outcome,
    nextSteps,
    meetingDate,
    agenda,
    additionalNotes,
    appointmentId,
  } = req.body;

  try {
    const query = `
      INSERT INTO progress_tracking (
        advisor_id, advisor_name, user_id, user_name, date, goal_type, goal,
        action_steps, timeline, progress_date, progress_made,
        effectiveness_date, outcome, next_steps, meeting_date, agenda, additional_notes, appointment_id
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
        $12, $13, $14, $15, $16, $17, $18
      )
    `;

    const values = [
      advisorId,
      advisorName,
      userId,
      userName,
      date,
      goalType,
      goal,
      actionSteps,
      timeline,
      progressDate,
      progressMade,
      effectivenessDate,
      outcome,
      nextSteps,
      meetingDate,
      agenda,
      additionalNotes,
      appointmentId,
    ];

    await pool.query(query, values);
    res.status(200).json({ message: 'Progress tracking details inserted successfully' });
  } catch (err) {
    console.error('Error inserting progress tracking details:', err);
    res.status(500).json({ error: 'Failed to insert progress tracking details', details: err.message });
  }
});

//get Appointments Per Month
app.get('/getAppointmentsForMonth', async (req, res) => {
  const { month, year } = req.query;

  try {
    const client = await pool.connect();

    const query = `
      SELECT * FROM appointments
      WHERE EXTRACT(MONTH FROM date) = $1
      AND EXTRACT(YEAR FROM date) = $2
    `;

    const result = await client.query(query, [month, year]);

    client.release();

    // Send the appointments data as JSON
    res.json(result.rows);

  } catch (err) {
    console.error('Error executing query', err.stack);
    res.status(500).send('Error retrieving appointments');
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
