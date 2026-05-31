import smtplib
import httpx
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.config import settings

_HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background:#F5ECD8;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F5ECD8;padding:32px 16px;">
    <tr><td align="center">
      <table width="520" cellpadding="0" cellspacing="0" style="max-width:520px;width:100%;background:#1C1208;border-radius:20px;overflow:hidden;font-family:Georgia,serif;">
        <tr>
          <td style="background:#2E1A0A;padding:30px 36px 24px;border-bottom:1px solid #3D2010;">
            <p style="margin:0 0 6px;font-size:10px;letter-spacing:5px;color:#C8942C;text-transform:uppercase;font-family:Arial,sans-serif;">RIMNAM CHANTHABUN · ริมน้ำจันทบูร</p>
            <h1 style="margin:0;font-size:24px;font-weight:bold;color:#F8F0DC;line-height:1.3;">รีเซ็ตรหัสผ่าน</h1>
            <p style="margin:8px 0 0;font-size:13px;color:#B87A44;font-family:Arial,sans-serif;">ใช้รหัส OTP ด้านล่างเพื่อตั้งรหัสผ่านใหม่ของคุณ</p>
          </td>
        </tr>
        <tr>
          <td style="padding:36px 36px 28px;">
            <p style="margin:0 0 14px;font-size:10px;letter-spacing:3px;color:#D4A55A;text-transform:uppercase;font-family:Arial,sans-serif;">รหัส OTP ของคุณ</p>
            <table width="100%" cellpadding="0" cellspacing="0">
              <tr>
                <td style="background:#2E1A0A;border:2px solid #C8942C;border-radius:16px;padding:28px 20px;text-align:center;">
                  <span style="font-size:46px;font-weight:bold;letter-spacing:18px;color:#C8942C;font-family:Courier,monospace;">{otp}</span>
                </td>
              </tr>
            </table>
            <table width="100%" cellpadding="0" cellspacing="0" style="margin-top:20px;">
              <tr>
                <td style="background:#2E1A0A;border-radius:10px;padding:14px 18px;">
                  <table cellpadding="0" cellspacing="0">
                    <tr>
                      <td style="font-size:18px;padding-right:10px;">&#x23F1;</td>
                      <td style="font-size:13px;color:#8B5230;font-family:Arial,sans-serif;">รหัสนี้จะหมดอายุใน <strong style="color:#E8C878;">15 นาที</strong> — อย่าแชร์กับผู้อื่น</td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#0D0804;padding:20px 36px;border-radius:0 0 20px 20px;">
            <p style="margin:0;font-size:11px;color:#5C3218;line-height:1.7;font-family:Arial,sans-serif;">
              หากคุณไม่ได้ร้องขอรหัสนี้ กรุณาเพิกเฉยต่ออีเมลนี้<br>
              บัญชีของคุณจะยังคงปลอดภัย
            </p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>"""


def send_otp_email(to_email: str, otp: str) -> None:
    html_body = _HTML_TEMPLATE.format(otp=otp)
    subject = "รหัส OTP สำหรับรีเซ็ตรหัสผ่าน — ริมน้ำจันทบูร"

    resend_key = settings.RESEND_API_KEY
    if resend_key and resend_key.startswith("re_"):
        _send_via_resend(to_email, subject, html_body)
    elif settings.BREVO_API_KEY:
        _send_via_brevo_api(to_email, subject, html_body)
    elif settings.SMTP_USER and settings.SMTP_PASSWORD:
        _send_via_smtp(to_email, subject, html_body)
    else:
        print(f"[DEV] OTP for {to_email}: {otp}", flush=True)


def _send_via_resend(to_email: str, subject: str, html_body: str) -> None:
    response = httpx.post(
        "https://api.resend.com/emails",
        headers={
            "Authorization": f"Bearer {settings.RESEND_API_KEY}",
            "Content-Type": "application/json",
        },
        json={
            "from": f"{settings.SMTP_FROM_NAME} <onboarding@resend.dev>",
            "to": [to_email],
            "subject": subject,
            "html": html_body,
        },
        timeout=15,
    )
    print(f"[Resend] status={response.status_code} body={response.text}")
    if response.status_code != 200:
        raise Exception(f"Resend {response.status_code}: {response.text}")


def _send_via_brevo_api(to_email: str, subject: str, html_body: str) -> None:
    sender_email = settings.SMTP_FROM_EMAIL or settings.SMTP_USER or "noreply@rimnam.app"
    response = httpx.post(
        "https://api.brevo.com/v3/smtp/email",
        headers={
            "api-key": settings.BREVO_API_KEY,
            "Content-Type": "application/json",
        },
        json={
            "sender": {"name": settings.SMTP_FROM_NAME, "email": sender_email},
            "to": [{"email": to_email}],
            "subject": subject,
            "htmlContent": html_body,
        },
        timeout=15,
    )
    if response.status_code not in (200, 201):
        raise Exception(f"Brevo API {response.status_code}: {response.text}")


def _send_via_smtp(to_email: str, subject: str, html_body: str) -> None:
    from_email = settings.SMTP_FROM_EMAIL or settings.SMTP_USER
    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = f"{settings.SMTP_FROM_NAME} <{from_email}>"
    msg["To"] = to_email
    msg.attach(MIMEText(html_body, "html", "utf-8"))

    with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
        server.starttls()
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        server.sendmail(settings.SMTP_USER, to_email, msg.as_string())
