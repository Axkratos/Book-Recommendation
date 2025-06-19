from langchain_core.tools import tool
from utils.validators import Validators
from utils.sheets import append_to_google_sheet
from utils.emailer import send_confirmation_email

@tool
def book_appointment_tool(name: str, phone: str, email: str, appointment_date: str) -> str:
    """Book an appointment with the provided user information"""
    # Validate email and phone
    if not Validators.validate_email(email):
        return "Invalid email format. Please provide a valid email address."
    
    if not Validators.validate_phone(phone):
        return "Invalid phone number. Please provide a valid phone number."
    
    try:
        append_to_google_sheet(name, phone, email, appointment_date)
    except Exception as e:
        return f"⚠️ Could not log to Google Sheet: {e}"

    try:
        send_confirmation_email(email, name, appointment_date)
    except Exception as e:
        return "⚠️ Booked, but failed to send email"
    
    return f"""
    ✅ Appointment Successfully Booked!
    
    Name: {name}
    Phone: {phone}
    Email: {email}
    Date: {appointment_date}
    
    You will receive a confirmation email shortly.
    """
