import cv2
import os

# Ask for folder name
name = input("Enter the name for the folder: ").strip()

# Create folder if it doesn't exist
folder_path = os.path.join(os.getcwd(), name)
os.makedirs(folder_path, exist_ok=True)

# Initialize webcam
cap = cv2.VideoCapture(0)

count = 0
total_images = 300

print(f"Capturing {total_images} images for {name}... Press 'q' to quit early.")

while count < total_images:
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame")
        break

    # Save image
    img_name = f"{name}_{count+1}.jpg"
    cv2.imwrite(os.path.join(folder_path, img_name), frame)
    count += 1

    # Show preview
    cv2.imshow("Capturing Images", frame)

    # Exit if 'q' pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

print(f"Saved {count} images in {folder_path}")

# Release and close
cap.release()
cv2.destroyAllWindows()
