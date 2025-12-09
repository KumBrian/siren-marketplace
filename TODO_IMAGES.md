# Image Upload Strategy

## Current Behavior

- When creating a catch, images are stored locally (as File paths) in the `Catch` entity.
- The `Catch` status is set to `Draft` (or `Available` if selling immediately, but currently images are still local).

## Required Implementation

1. **Draft Mode**:

   - Store images as local file paths.
   - Do NOT upload to server yet.
   - App must handle displaying local `File` images.

2. **Publishing (Listing to Marketplace)**:
   - When transitioning from `Draft` to `Available` (or upon initial listing if skipping draft):
     - Iterate through local image paths.
     - Upload each image to the backend's **Image Storage Endpoint**.
     - Receive public URL for each image.
     - Update the `Catch` entity with these new URLs.
     - Send the final `Catch` object (with URLs) to the `create` or `update` endpoint.

## Backend Constraints

- Determine the specific Image Upload Endpoint.
- Ensure the `Catch` creation/update endpoint expects URLs, not binary data.

## Todo

- [ ] Implement `ImageRepository` to handle uploads.
- [ ] Update `AddCatchNotifier.submit()` to handle the upload process if "Selling" is true.
- [ ] Create a background job or explicit step to sync Draft images when publishing.
