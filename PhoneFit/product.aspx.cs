using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PhoneFit.BackendServiceReference;

namespace PhoneFit
{
    public partial class product : System.Web.UI.Page
    {
        Service1Client client = new Service1Client();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int phoneModelID;
                if(!int.TryParse(Request.QueryString["id"], out phoneModelID))
                {
                    Response.Redirect("Home.aspx");
                    return;
                }

                // Find the requested phone
                PhoneCatalogue phone = client.GetPhoneByID(phoneModelID);

                // Phone could not be located
                if(phone == null)
                {
                    Response.Redirect("Home.aspx");
                    return;
                }

                // Display the selected phone details
                imgMainPhone.ImageUrl = phone.ImagePath;
                lblModelName.Text = phone.ModelName;
                lblDescription.Text = phone.Description;
                lblBrandName.Text = phone.BrandName;
                lblStartingPrice.Text = phone.StartingPrice.ToString("N2");
                lblStockQuantity.Text = phone.StockQuantity.ToString();

                // Find the specs related to the phone
                PhoneSpecification specification = client.GetSpecificationByPhoneID(phoneModelID);

                if(specification != null)
                {
                    // Display the phone specs
                    lblProcessor.Text = specification.Processor;
                    lblDisplay.Text = specification.ScreenSize.ToString().Replace(",", ".") + " inch " + specification.ScreenType;
                    lblRefreshRate.Text = specification.RefreshRate.ToString() + " Hz";
                    lblBattery.Text = specification.BatteryCapacity.ToString() + " mAh";
                    lblRearCamera.Text = specification.RearCameraMP.ToString().Replace(",", ".") + " MP";
                    lblFrontCamera.Text = specification.FrontCameraMP.ToString().Replace(",", ".") + " MP";
                    lblSupports5G.Text = specification.Supports5G ? "Yes" : "No";
                    lblDualSIM.Text = specification.DualSIM ? "Yes" : "No";
                    lblExpandableStorage.Text = specification.ExpandableStorage ? "Yes" : "No";
                    lblWaterResistance.Text = specification.WaterResistance;
                }

                // Find and display the active variants related to the phone
                var variants = client.GetVariantsByPhoneID(phoneModelID);
                rptVariants.DataSource = variants;
                rptVariants.DataBind();

            }
           
        }

        protected void rptVariants_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Check that the user clicked the SelectVariant command
            if (e.CommandName == "SelectVariant")
            {
                // Get the VariantID from the variant button that was clicked
                int variantID = Convert.ToInt32(e.CommandArgument);

                // Get the phone model id from the page URL
                int phoneModelID;
                if (!int.TryParse(Request.QueryString["id"], out phoneModelID))
                {
                    Response.Redirect("shop.aspx");
                    return;
                }

                // Get all active variants belonging to the selected phone
                var variants = client.GetVariantsByPhoneID(phoneModelID);

                // Search the variants and the find the variant whose variantID matches the button the user clicked
                var selectedVariant =
                    variants.FirstOrDefault(
                        variant => variant.VariantID == variantID
                    );

                if (selectedVariant != null)
                {
                    // Remember the selected VariantID
                    // The hiddenfield is not visible to the user
                    // We can retrieve this value later when the user clicks Add to Cart
                    hfSelectedVariantID.Value = selectedVariant.VariantID.ToString();

                    // Display the variants details
                    lblStartingPrice.Text =selectedVariant.Price.ToString("N2");
                    lblStockQuantity.Text = selectedVariant.StockQuantity.ToString();

                    // Indicate which variant was selected
                    lblMessage.ForeColor =System.Drawing.Color.Green;
                    lblMessage.Text = selectedVariant.RAMGB + " GB RAM, " + selectedVariant.StorageGB + " GB Storage, " + selectedVariant.Colour + " selected.";
                }
            }
        }


        // Click Add to Cart
        // Is there a logged-in user?
        // Is the logged-in user a Customer?
        // Get UserID from Session
        // Check selected VariantID
        // Check quantity
        // Call WCF AddToCart()
        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            // Check whether a user is currently logged in
            if(Session["UserID"] == null || Session["RoleName"] == null)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Please log in before adding a phone to your cart.";
                return;
            }

            // Only customers should have access to the shopping cart
            if(Session["RoleName"].ToString() != "Customer")
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Only valid customer accounts can add products to the cart.";
                return;
            }

            // Get the logged in customers user id from the session
            int userID = Convert.ToInt32(Session["UserID"]);

            // Validate the quantity controls on the page
            Page.Validate("CartGroup");

            if (!Page.IsValid)
            {
                return;
            }

            // Get the variantID that was stored when the customer selected a phone variant
            int variantID;
            if (!int.TryParse(hfSelectedVariantID.Value, out variantID))
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Please select a phone variant first.";
                return;
            }

            // Get and validate the quantity entered by the user
            int quantity;
            if (!int.TryParse(txtQuantity.Text, out quantity) || quantity <= 0)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Please enter a valid quantity.";
                return;
            }

            // Send the logged in customers userID, selected variantID and quantity to the WCF service
            bool phoneAdded = client.AddToCart(userID, variantID, quantity);

            if (phoneAdded)
            {
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "The selected phone was added to your cart.";
                txtQuantity.Text = "1";
            }
            else
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "The item could not be added. Check the available stock.";
            }
        }

    }
}