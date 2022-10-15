const image_input = document.querySelector("#image-input");
// const floor_plan_button = document.querySelector("div.next-page-button button");
// const rc_output_button = document.querySelector("button"); 

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


// // show the image from yolov5
// floor_plan_button.addEventListener("click", function() {
//   // this element is supposed to first call requestRooms
//   requestRooms();
//   alert('made it to floor plan button')
//   // check if the processing of the image was complete
//   if (xhr.steadyState == 4 && xhr.status == 201){
//     // plot the result from file 
//     show_image('../backend/2R1C_simulation/plot.png', 
//                  500, 
//                  400, 
//                  'The result of the modelling');
//   }
// });

// // show the resut from RC
// rc_output_button.addEventListener("click", function() {
//   // this element is supposed to first call requestRC
//   requestRC();
//   // and then listen to ACK, from which retrieve the image 
//   // and plot it
//   if (xhr.steadyState == 4 && xhr.status == 201){
//     // plot the result from file 
//     show_image('../backend/2R1C_simulation/plot.png', 
//                  500, 
//                  400, 
//                  'The result of the modelling');  }
// });

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

function requestRooms(){
  console.log("Sending the rooms request");
  xhr = getXmlHttpRequestObject();
  // asynchronous request
  xhr.open("GET", "http://localhost:6969/rooms", true);
  // Send nothing
  xhr.send(null);
}

function requestRC(){
  console.log("Sending the modelling result request");
  xhr = getXmlHttpRequestObject();
  // asynchronous request
  xhr.open("GET", "http://localhost:6969/rc", true);
  // Send nothing
  xhr.send(null);
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