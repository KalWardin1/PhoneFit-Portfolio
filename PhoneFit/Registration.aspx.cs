using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PhoneFit.BackendServiceReference;

namespace PhoneFit
{
    public partial class Registration : System.Web.UI.Page
    {
        Service1Client client = new Service1Client();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Field validation
            Page.Validate("RegistrationGroup");
            if (!Page.IsValid)
            {
                return;
            }

            string password = txtPassword.Text;
            string hashedPassword = SecrecyHash.hashFunction(password);

            UserAccount newUser = new UserAccount
            {
                UserEmail = txtEmail.Text.Trim(),
                UserPasswordHash = hashedPassword,
                UserFirstName = txtFirstName.Text.Trim(),
                UserSurname = txtSurname.Text.Trim(),
                UserPhoneNumber = txtPhoneNumber.Text.Trim()
            };

            int result = client.RegisterUser(newUser);

            if (result == 0)
            {
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "Registration successful. Please use the log in link below.";
            }
            else if (result == 2)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "An account with this email already exists.";
            }
            else
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Registration failed. Please try again.";
            }
        }
    }
}