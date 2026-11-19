using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PhoneFit.BackendServiceReference;

namespace PhoneFit
{
    public partial class PhoneFitMaster : System.Web.UI.MasterPage
    {
        Service1Client client = new Service1Client();

        protected void Page_Load(object sender, EventArgs e)
        {
            // set navigation for the current user role
            DisplayNavigation();

            // default the cart has 0 items
            lblCartCount.Text = "0";

            // only retrieve a cart when a customer is logged in
            if(Session["UserID"] != null && Session["RoleName"] != null && Session["RoleName"].ToString() == "Customer")
            {
                // get the logged in customer id
                int userID = Convert.ToInt32(Session["UserID"]);

                // get the customers cart items
                CartItemInfo[] cartItems = client.GetCartItems(userID);

                int cartCount = 0;

                // add the quantity of every item inside the cart
                if(cartItems != null)
                {
                    foreach(CartItemInfo item in cartItems)
                    {
                        cartCount += item.Quantity;
                    }
                }

                // display the total quantity beside the cart
                lblCartCount.Text = cartCount.ToString();
            }

        }

        private void DisplayNavigation()
        {
            // default navigation for a user who is not logged in
            lnkLogin.Visible = true;
            btnLogout.Visible = false;

            lnkShop.Visible = true;
            lnkCart.Visible = true;
            lnkMyOrders.Visible = false;
            lnkManagerDashboard.Visible = false;

            pnlBrowsePhones.Visible = true;
            pnlCartIcon.Visible = true;

            lnkAccount.NavigateUrl = "~/Login.aspx";

            // no logged in role exists keep the default navigation
            if (Session["RoleName"] == null)
            {
                return;
            }

            string roleName = Session["RoleName"].ToString();

            // logged in Customer navigation
            if (roleName == "Customer")
            {
                lnkLogin.Visible = false;
                btnLogout.Visible = true;

                lnkShop.Visible = true;
                lnkCart.Visible = true;
                lnkMyOrders.Visible = true;
                lnkManagerDashboard.Visible = false;

                pnlBrowsePhones.Visible = true;
                pnlCartIcon.Visible = true;

                // access to previous ordrrs and invoices
                lnkAccount.NavigateUrl = "~/MyOrders.aspx";
            }

            // logged in Manager navigation
            else if (roleName == "Manager")
            {
                lnkLogin.Visible = false;
                btnLogout.Visible = true;

                lnkShop.Visible = false;
                lnkCart.Visible = false;
                lnkMyOrders.Visible = false;
                lnkManagerDashboard.Visible = true;

                pnlBrowsePhones.Visible = false;
                pnlCartIcon.Visible = false;

                lnkAccount.NavigateUrl = "~/Manager.aspx";
            }
        }


        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // remove all session variables belonging to the logged in user
            Session.Clear();

            // redirect the user back to the login page
            Response.Redirect("Login.aspx");
        }
    }
}