Key changes:

- `MultiSelectDropdown`:** Replaced the default `CheckboxListTile` with a custom `InkWell` and
  `Row` layout. This provides more control over padding and alignment of the checkbox and text.
- `CatchDetails` Screen:**
    - The "Filter" button is now only displayed on the "Offers" tab, while the "Date" sort button
      remains visible on all tabs.
    - Added a fallback image to be displayed if a catch image fails to load.
- `Notifications` Screen:** The search bar has been temporarily commented out.
- `ForSaleCard` Widget:** Implemented an error builder to show a default image if the primary
  catch image fails to load.
- Replaced the `moneybag` icon with a new filled variant (`moneybag_filled`) for better visual
  feedback on updated offers.
- Introduced a `ProductImagesCarousel` widget to standardize image display and viewing across
  product and offer details screens.
- Offer Creation & Details:
    - Improved the "Make Offer" dialog with interactive price calculation: updating weight
      automatically adjusts the total price, and vice-versa.
    - Added a flag called `waitingFor` to the offer model which holds the user role so as to fix the
      counter logic which permitted the fisher make multiple counters. So now, when an offer or
      counter is made, the `waitingFor` holds the role that has to take the next step. There is
      currently no flow to show the buyer actions for offers. i.e for accepting, rejecting and
      countering offers. Right now, only the buyer can do those actions. I added comments for @Ganna on this.
    - Refactored the action buttons on `BuyerOfferDetails` and `OrderDetails` to be context-aware,
      showing relevant actions (e.g., "Make New Offer", "Call Seller", "Rate Fisher") based on the
      offer's status.
    - Added a "success" confirmation dialog that auto-dismisses after an offer is sent.
- Filter Indicator:
    - Added a badge to the filter button on the buyer's home screen, which now displays a count of
      active filters.
- Data Seeding:
    - Updated the seeder to assign a random number of images (1-4) to each generated `Catch`, making
      test data more realistic.