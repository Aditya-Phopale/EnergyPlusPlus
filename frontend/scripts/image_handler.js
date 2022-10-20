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
  xhr.open("POST", "http://localhost:6969/image", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  // Send image over the network
  xhr.send(JSON.stringify(uploaded_image));
}


//https://stackoverflow.com/questions/5451445/how-to-display-image-with-javascript
function show_image(src, width, height, alt) {
  var img = document.createElement("img");
  img.src = src;
  img.width = width;
  img.height = height;
  img.alt = alt;

  // This next line will just add it to the <body> tag
  document.body.appendChild(img);
}

function switch_to_page(src){
//  if (xhr.status == 201 || xhr.status == 500){
    location.href=src;
//  }
}

function Sleep(milliseconds) {
  return new Promise(resolve => setTimeout(resolve, milliseconds));
 }