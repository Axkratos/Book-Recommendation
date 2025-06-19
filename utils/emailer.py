import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_confirmation_email(to_email, name, appointment_date):
    """Send appointment confirmation email"""
    host = os.getenv("SMTP_HOST")
    port = int(os.getenv("SMTP_PORT", 587))
    sender = os.getenv("SMTP_SENDER_EMAIL")
    password = os.getenv("SMTP_SENDER_PASSWORD")

    body = f"Hi {name},\n\n✅ Your appointment is booked for {appointment_date}.\n\nThank you!"
    msg = MIMEMultipart()
    msg["From"], msg["To"], msg["Subject"] = sender, to_email, "Appointment Confirmation"
    msg.attach(MIMEText(body, "plain"))

    with smtplib.SMTP(host, port) as server:
        server.starttls()
        server.login(sender, password)
        server.send_message(msg)
