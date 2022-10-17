// const rc_output_button = document.querySelector("button"); 

var xhr = null;

getXmlHttpRequestObject = function () {
  if (!xhr) {
      // Create a new XMLHttpRequest object 
      xhr = new XMLHttpRequest();
  }
  return xhr;
};

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

function requestRC(){
  console.log("Sending the modelling result request");
  xhr = getXmlHttpRequestObject();
  // asynchronous request
  xhr.open("GET", "http://localhost:6969/rc", true);
  // Send nothing
  xhr.send(null);
}
