<?php
// Form submission handler for JP IT Staffing contact form

// Allow CORS if needed
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Check if form is submitted via POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    
    // Sanitize and validate input
    $name = filter_var(trim($_POST['name']), FILTER_SANITIZE_STRING);
    $email = filter_var(trim($_POST['email']), FILTER_SANITIZE_EMAIL);
    $phone = filter_var(trim($_POST['phone']), FILTER_SANITIZE_STRING);
    $service = filter_var(trim($_POST['service']), FILTER_SANITIZE_STRING);
    $message = filter_var(trim($_POST['message']), FILTER_SANITIZE_STRING);
    
    // Initialize error array
    $errors = array();
    
    // Validate required fields
    if (empty($name)) {
        $errors[] = "Name is required";
    }
    
    if (empty($email)) {
        $errors[] = "Email is required";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Invalid email format";
    }
    
    if (empty($message)) {
        $errors[] = "Message is required";
    }
    
    // If there are errors, return them
    if (!empty($errors)) {
        echo json_encode([
            'success' => false,
            'errors' => $errors
        ]);
        exit;
    }
    
    // Email configuration
    $to = "info@jpitstaffing.com"; // Change this to your email
    $subject = "New Contact Form Submission from " . $name;
    
    // Email body
    $email_body = "You have received a new message from JP IT Staffing contact form.\n\n";
    $email_body .= "Name: " . $name . "\n";
    $email_body .= "Email: " . $email . "\n";
    $email_body .= "Phone: " . $phone . "\n";
    $email_body .= "Service Interested: " . $service . "\n\n";
    $email_body .= "Message:\n" . $message . "\n";
    
    // Email headers
    $headers = "From: " . $email . "\r\n";
    $headers .= "Reply-To: " . $email . "\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion();
    
    // Send email
    if (mail($to, $subject, $email_body, $headers)) {
        // Success response
        echo json_encode([
            'success' => true,
            'message' => 'Thank you! Your message has been sent successfully.'
        ]);
        
        // Optional: Save to database
        // saveToDatabase($name, $email, $phone, $service, $message);
        
        // Optional: Send auto-reply to user
        sendAutoReply($email, $name);
        
    } else {
        // Error response
        echo json_encode([
            'success' => false,
            'message' => 'Oops! Something went wrong. Please try again later.'
        ]);
    }
    
} else {
    // Not a POST request
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

// Function to send auto-reply (optional)
function sendAutoReply($to_email, $name) {
    $subject = "Thank you for contacting JP IT Staffing";
    
    $message = "Dear " . $name . ",\n\n";
    $message .= "Thank you for reaching out to JP IT Staffing. We have received your message and will get back to you shortly.\n\n";
    $message .= "Our team typically responds within 24 hours during business days.\n\n";
    $message .= "Best regards,\n";
    $message .= "JP IT Staffing Team\n";
    $message .= "info@jpitstaffing.com\n";
    $message .= "+1 (555) 123-4567";
    
    $headers = "From: info@jpitstaffing.com\r\n";
    $headers .= "Reply-To: info@jpitstaffing.com\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion();
    
    mail($to_email, $subject, $message, $headers);
}

// Function to save to database (optional)
function saveToDatabase($name, $email, $phone, $service, $message) {
    // Database configuration
    $servername = "localhost";
    $username = "your_username";
    $password = "your_password";
    $dbname = "jp_it_staffing";
    
    try {
        // Create connection
        $conn = new mysqli($servername, $username, $password, $dbname);
        
        // Check connection
        if ($conn->connect_error) {
            throw new Exception("Connection failed: " . $conn->connect_error);
        }
        
        // Prepare and bind
        $stmt = $conn->prepare("INSERT INTO contact_submissions (name, email, phone, service, message, submitted_at) VALUES (?, ?, ?, ?, ?, NOW())");
        $stmt->bind_param("sssss", $name, $email, $phone, $service, $message);
        
        // Execute
        $stmt->execute();
        
        // Close connections
        $stmt->close();
        $conn->close();
        
        return true;
    } catch (Exception $e) {
        // Log error
        error_log("Database error: " . $e->getMessage());
        return false;
    }
}
?>
