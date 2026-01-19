import React from 'react';
import { useForm, ValidationError } from '@formspree/react';

function ContactForm() {
  const [state, handleSubmit] = useForm("contactForm");

  if (state.succeeded) {
    return (
      <div style={{ textAlign: 'center', padding: '20px', color: '#00d1ff' }}>
        <h2>Thanks for reaching out!</h2>
        <p>We'll get back to you soon.</p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} style={styles.form}>
      <h2>Contact Us</h2>

      <label htmlFor="email">Email Address</label>
      <input
        id="email"
        type="email"
        name="email"
        placeholder="you@example.com"
        style={styles.input}
        required
      />
      <ValidationError prefix="Email" field="email" errors={state.errors} />

      <label htmlFor="message">Message</label>
      <textarea
        id="message"
        name="message"
        placeholder="Your message here..."
        style={styles.textarea}
        required
      />
      <ValidationError prefix="Message" field="message" errors={state.errors} />

      <button type="submit" disabled={state.submitting} style={styles.button}>
        {state.submitting ? "Sending..." : "Submit"}
      </button>
    </form>
  );
}

const styles = {
  form: {
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '500px',
    margin: '40px auto',
    padding: '20px',
    backgroundColor: '#1a1c29',
    borderRadius: '12px',
    color: '#e0e0e0',
    boxShadow: '0 0 20px #00d1ff',
  },
  input: {
    padding: '10px',
    margin: '10px 0 20px 0',
    borderRadius: '6px',
    border: '1px solid #00d1ff',
    backgroundColor: '#12131f',
    color: '#fff',
  },
  textarea: {
    padding: '10px',
    margin: '10px 0 20px 0',
    minHeight: '100px',
    borderRadius: '6px',
    border: '1px solid #00d1ff',
    backgroundColor: '#12131f',
    color: '#fff',
    resize: 'vertical',
  },
  button: {
    padding: '12px',
    borderRadius: '6px',
    border: 'none',
    backgroundColor: '#00d1ff',
    color: '#12131f',
    fontWeight: 'bold',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
  },
};

export default ContactForm;
