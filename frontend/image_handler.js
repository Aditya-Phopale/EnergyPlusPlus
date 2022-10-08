const image_input = document.querySelector("#image-input");

var xhr = null;
var uploaded_image = null;

getXmlHttpRequestObject = function () {
  if (!xhr) {
      // Create a new XMLHttpRequest object 
      xhr = new XMLHttpRequest();
  }
  return xhr;
};

// get and show an image from user
image_input.addEventListener("change", function() {
  const reader = new FileReader();
  reader.addEventListener("load", () => {
    uploaded_image = reader.result;
    document.querySelector("#display-image").style.backgroundImage = `url(${uploaded_image})`;
  });
  reader.readAsDataURL(this.files[0]);
});

function approvePlan(){
  sendImage();
  // redirect to the next page
}

function sendImage(){
  console.log("Sending the image");
  xhr = getXmlHttpRequestObject();
  // asynchronous request
  xhr.open("POST", "http://localhost:6969/", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  // Send image over the network
  xhr.send(JSON.stringify(uploaded_image));
}
