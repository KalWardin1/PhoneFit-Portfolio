<%@ Page Title="Shop Phones" Language="C#" MasterPageFile="~/Phonefit.Master" AutoEventWireup="true" CodeBehind="shop.aspx.cs" Inherits="PhoneFit.shop" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <section class="page-head">
      <div class="container">
        <div class="crumbs"><a href="Home.aspx">Home</a> <span class="sep">›</span> <span>Shop Phones</span>
        </div>
            <h1>Shop Smartphones</h1>
            <p>
                Browse PhoneFit's available smartphones and select a device
                to view its variants, price, stock and specifications.
            </p>
      </div>
    </section>

    <section class="section">
      <div class="container">
          <div>
            <div class="shop-toolbar">
                <asp:Label ID="lblPhoneCount" runat="server" CssClass="count"></asp:Label>
                <div style="display:flex; gap:var(--s3); align-items:center;">
                    <span style="
                        font-size:var(--text-xs);
                        color:var(--fg-mute);
                        font-family:var(--ff-mono);">
                        SORT
                    </span>
                    <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                        <asp:ListItem Text="Default"
                            Value="Default" Selected="True">
                        </asp:ListItem>

                        <asp:ListItem Text="Name: A to Z"
                            Value="NameAZ">
                        </asp:ListItem>

                        <asp:ListItem Text="Price: Low to High"
                            Value="PriceLow">
                        </asp:ListItem>

                        <asp:ListItem Text="Price: High to Low"
                            Value="PriceHigh">
                        </asp:ListItem>

                    </asp:DropDownList>
                </div>
            </div>

            <div class="shop-grid">
                <asp:Repeater ID="rptPhones" runat="server">
                    <ItemTemplate>
                        <article class="product-card">
                            <div class="img-wrap">
                                <span class="badge">Available</span>

                                <asp:Image ID="imgPhone" runat="server"
                                    ImageUrl='<%# Eval("ImagePath") %>'
                                    AlternateText='<%# Eval("ModelName") %>' />
                            </div>

                            <div class="stock">
                                <span class="dot"></span>
                                In stock · <%# Eval("StockQuantity") %> items
                            </div>

                            <div style="font-family: var(--ff-mono); font-size: 11px; color: var(--fg-mute);">
                                <%# Eval("BrandName") %>
                            </div>

                            <a href='<%# "product.aspx?id=" + Eval("PhoneModelID") %>'
                                class="name">
                                <%# Eval("ModelName") %>
                            </a>

                            <p>
                                <%# Eval("Description") %>
                            </p>

                            <div class="price">
                                <span class="now">
                                    From R<%# Eval("StartingPrice", "{0:N2}") %>
                                </span>
                            </div>

                            <a href='<%# "product.aspx?id=" + Eval("PhoneModelID") %>'
                                class="btn">
                                View Details &#8594;
                            </a>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            </div>

          </div>
    </section>

</asp:Content>