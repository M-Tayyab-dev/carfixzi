import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional
import httpx

class EmailService:
    """
    CARFIXZI Enterprise Email Service
    Supports Resend API, SendGrid API, and standard SMTP (Gmail / Custom Domain).
    Generates beautifully branded responsive HTML emails with CARFIXZI brand identity.
    """

    def __init__(self):
        self.provider = os.getenv("EMAIL_PROVIDER", "resend").lower() # 'resend', 'sendgrid', 'smtp'
        self.api_key = os.getenv("EMAIL_API_KEY", "")
        self.from_email = os.getenv("EMAIL_FROM", "CARFIXZI <support@carfixzi.pk>")
        
        # SMTP fallback settings
        self.smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_user = os.getenv("SMTP_USER", "")
        self.smtp_pass = os.getenv("SMTP_PASS", "")

    def get_branded_template(
        self,
        headline: str,
        greeting: str,
        body_text: str,
        cta_label: Optional[str] = None,
        cta_url: Optional[str] = None,
        info_box: Optional[str] = None,
    ) -> str:
        """
        Responsive branded CARFIXZI HTML email template matching app design system:
        - Primary Navy: #1B365D
        - Accent Gold: #E5A93C
        - Dark Slate: #2D3142
        - Surface: #F8F9FA
        """
        cta_button_html = ""
        if cta_label and cta_url:
            cta_button_html = f"""
            <table border="0" cellpadding="0" cellspacing="0" style="margin: 28px 0;">
                <tr>
                    <td align="center" style="border-radius: 8px; background: #E5A93C;">
                        <a href="{cta_url}" target="_blank" style="font-size: 15px; font-family: 'Segoe UI', Helvetica, Arial, sans-serif; color: #1B365D; text-decoration: none; border-radius: 8px; padding: 14px 28px; border: 1px solid #E5A93C; display: inline-block; font-weight: 700; letter-spacing: 0.5px;">
                            {cta_label} &rarr;
                        </a>
                    </td>
                </tr>
            </table>
            """

        info_box_html = ""
        if info_box:
            info_box_html = f"""
            <div style="background-color: #F0F4F8; border-left: 4px solid #1B365D; padding: 14px 18px; margin: 20px 0; border-radius: 0 6px 6px 0;">
                <p style="margin: 0; color: #2D3142; font-size: 13px; line-height: 1.5;">{info_box}</p>
            </div>
            """

        return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{headline} - CARFIXZI</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F4F6F9; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; background-color: #F4F6F9; padding: 30px 10px;">
        <tr>
            <td align="center">
                <!-- Main Container -->
                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 580px; background-color: #FFFFFF; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 16px rgba(27, 54, 93, 0.08); border: 1px solid rgba(45, 49, 66, 0.08);">
                    
                    <!-- Header Banner -->
                    <tr>
                        <td align="center" style="background: linear-gradient(135deg, #1B365D 0%, #2D3142 100%); padding: 32px 20px;">
                            <!-- Logo Circle -->
                            <table border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="width: 68px; height: 68px; background-color: #FFFFFF; border-radius: 50%; border: 3px solid #E5A93C; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
                                        <img src="https://raw.githubusercontent.com/M-Tayyab-dev/carfixzi/master/assets/images/logo.png" alt="CARFIXZI Logo" width="56" height="56" style="display: block; border-radius: 50%; object-fit: cover;" onerror="this.style.display='none'" />
                                    </td>
                                </tr>
                            </table>
                            <h1 style="color: #FFFFFF; margin: 14px 0 0 0; font-size: 24px; font-weight: 800; letter-spacing: 2px;">CARFIXZI</h1>
                            <p style="color: #E5A93C; margin: 4px 0 0 0; font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase;">Verified Automotive Marketplace &bull; Sahiwal Pilot</p>
                        </td>
                    </tr>

                    <!-- Body Content -->
                    <tr>
                        <td style="padding: 36px 32px;">
                            <h2 style="color: #1B365D; font-size: 20px; font-weight: 700; margin: 0 0 16px 0;">{headline}</h2>
                            <p style="color: #2D3142; font-size: 15px; line-height: 1.6; margin: 0 0 14px 0;">{greeting},</p>
                            <div style="color: #4A5568; font-size: 14px; line-height: 1.6; margin: 0 0 20px 0;">
                                {body_text}
                            </div>
                            
                            {info_box_html}
                            {cta_button_html}
                            
                            <p style="color: #718096; font-size: 13px; line-height: 1.5; margin: 24px 0 0 0;">
                                If you did not make this request or have questions, please reach out to our local Sahiwal support desk at <a href="mailto:support@carfixzi.pk" style="color: #1B365D; font-weight: 600;">support@carfixzi.pk</a>.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #F8F9FA; padding: 24px 32px; border-top: 1px solid #EDF2F7; text-align: center;">
                            <p style="color: #A0AEC0; font-size: 12px; margin: 0 0 6px 0;">
                                &copy; 2026 CARFIXZI Pakistan. All rights reserved.
                            </p>
                            <p style="color: #A0AEC0; font-size: 11px; margin: 0;">
                                Sahiwal Bypass &bull; High Court Bench Road &bull; Punjab, Pakistan
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>"""

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
    ) -> dict:
        """
        Sends an email using configured provider (Resend, SendGrid, or SMTP).
        """
        if not to_email:
            return {"status": "error", "message": "Recipient email is required"}

        # 1. Resend API (Recommended: simple REST API with 100 free emails/day)
        if self.provider == "resend" and self.api_key:
            try:
                async with httpx.AsyncClient() as client:
                    resp = await client.post(
                        "https://api.resend.com/emails",
                        headers={
                            "Authorization": f"Bearer {self.api_key}",
                            "Content-Type": "application/json",
                        },
                        json={
                            "from": self.from_email,
                            "to": [to_email],
                            "subject": subject,
                            "html": html_content,
                        },
                        timeout=10.0,
                    )
                    if resp.status_code in [200, 201]:
                        return {"status": "success", "id": resp.json().get("id")}
                    return {"status": "error", "details": resp.text}
            except Exception as e:
                return {"status": "error", "exception": str(e)}

        # 2. SendGrid API
        elif self.provider == "sendgrid" and self.api_key:
            try:
                async with httpx.AsyncClient() as client:
                    resp = await client.post(
                        "https://api.sendgrid.com/v3/mail/send",
                        headers={
                            "Authorization": f"Bearer {self.api_key}",
                            "Content-Type": "application/json",
                        },
                        json={
                            "personalizations": [{"to": [{"email": to_email}]}],
                            "from": {"email": "noreply@carfixzi.pk", "name": "CARFIXZI"},
                            "subject": subject,
                            "content": [{"type": "text/html", "value": html_content}],
                        },
                        timeout=10.0,
                    )
                    if resp.status_code in [200, 202]:
                        return {"status": "success", "provider": "sendgrid"}
                    return {"status": "error", "details": resp.text}
            except Exception as e:
                return {"status": "error", "exception": str(e)}

        # 3. SMTP (Standard Gmail or custom server)
        elif self.smtp_user and self.smtp_pass:
            try:
                msg = MIMEMultipart("alternative")
                msg["Subject"] = subject
                msg["From"] = self.from_email
                msg["To"] = to_email
                msg.attach(MIMEText(html_content, "html"))

                with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                    server.starttls()
                    server.login(self.smtp_user, self.smtp_pass)
                    server.sendmail(self.from_email, [to_email], msg.as_string())
                return {"status": "success", "provider": "smtp"}
            except Exception as e:
                return {"status": "error", "exception": str(e)}

        # Fallback simulated response
        return {
            "status": "simulated",
            "message": "Email rendered successfully. Awaiting API key to dispatch to live mailbox.",
            "to": to_email,
            "subject": subject,
        }
