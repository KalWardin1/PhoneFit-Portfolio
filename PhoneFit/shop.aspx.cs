using System;
using PhoneFit.BackendServiceReference;

namespace PhoneFit
{
    public partial class shop : System.Web.UI.Page
    {
        Service1Client client = new Service1Client();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DisplayPhones();
            }
        }

        private void DisplayPhones()
        {
            PhoneCatalogue[] phones;

            // sort by model name A to Z
            if (ddlSort.SelectedValue == "NameAZ")
            {
                phones = client.GetActivePhonesByName();
            }

            // sort by price low to high
            else if (ddlSort.SelectedValue == "PriceLow")
            {
                phones = client.GetActivePhonesPriceLowToHigh();
            }

            // sort by price high to low
            else if(ddlSort.SelectedValue == "PriceHigh")
            {
                phones = client.GetActivePhonesPriceHighToLow();
            }
            else
            {
                // no sorting selected
                phones = client.GetActivePhones();
            }

            // no phones found
            if (phones == null || phones.Length == 0)
            {
                lblPhoneCount.Text = "No smartphones available.";

                rptPhones.DataSource = null;
                rptPhones.DataBind();

                return;
            }

            // how the actual number of phones
            lblPhoneCount.Text = "Showing " + phones.Length + " smartphones";

            // display the sorted phones
            rptPhones.DataSource = phones;
            rptPhones.DataBind();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            DisplayPhones();
        }
    }
}