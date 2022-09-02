//Calculation Controller//////////////////////////
const countWord =(val)=>{
  let count = val.match(/\S+/g);
  let arrCount = Array.from(count);
  console.log(arrCount)

  //Match returns a list.
  //Match() Parameter's default formatting with no parameteres is: match(/<input>/g)
  //The "\S+" makes the match() focus on literally all words separated by a space.
  //If the sentence we put in this function was "The dog was red",
  //Using match(/ \S+ /g) will return "The,dog,was,red": a nodeList with a length of 4.

  return {
    words: arrCount ? arrCount.length : 0,
  }
}


//UI Controller////////////////////////////////////
const DOMstrings = {
  textContent: document.getElementById("text-content"),
  wordCountValue: document.getElementById("word-count-value"),

  birdExpWords: document.getElementById("bird-exp-words"),
  birdExpValue: document.getElementById("bird-exp-value"),
  birdExpDivider: document.getElementById("bird-exp-divider"),
  birdExpGoal: document.getElementById("bird-exp-goal"),

  birdImages: document.querySelector(".bird-image"),

  customWordGoal: document.getElementById("custom-word-goal"),
  customizeGoal: document.getElementById("customize-goal"),
  totalWordGoal: document.getElementById("total-word-goal")
};

const nextBird=(birdStage)=>{
  let images = DOMstrings.birdImages.src.split("x");
  images[1] = birdStage;
  
  let nextImage = images.toString();
  nextImage = nextImage.replace(/,/g, "x");

  DOMstrings.birdImages.src = nextImage;

  return [nextImage];
}

const nextStage=(x)=>{
  if (x == 0){
    console.log("stage is nothing")
  } else if (x == 1){
    console.log(x)
    alert ("stage 1")
    console.log("alert stage is", x)
  } else if (x == 2){
    console.log(x)
    alert ("stage 2")
    console.log("alert stage is", x)
  } else if (x == 3){
    console.log(x)
    alert ("final stage")
    console.log("alert stage is", x)
  } else {
    alert("Next Stage error")
  }
}

//Global App Controller/////////////////////////////
let alertStage = [0,1,2,3];

//Text Editor tools:
var commandButtons = document.querySelectorAll(".editor-commands button");
for (var i = 0; i < commandButtons.length; i++) {
    commandButtons[i].addEventListener("mousedown", function (e) {
        e.preventDefault();
        var commandName = e.target.getAttribute("data-command");
        if (commandName === "html") {
            var commandArgument = e.target.getAttribute("data-command-argument");
            document.execCommand('formatBlock', false, commandArgument);
        } else {
            document.execCommand(commandName, false);
        }
    });
}



//1.) Word Counts Event Listener:
DOMstrings.customizeGoal.addEventListener("click", function () {
  if(DOMstrings.customWordGoal.value == 0){
      alert("Please enter a valid number")
    } else if (DOMstrings.customWordGoal.value > 0) {
      alert("Goal has been changed")
      DOMstrings.totalWordGoal.innerHTML = DOMstrings.customWordGoal.value;
      DOMstrings.customWordGoal.value = ""
    } else {
      alert("error")
    }
  })

DOMstrings.textContent.addEventListener("input", function () {
  let allWords = countWord(this.textContent);
  let wordCount = allWords.words;
  let birdCount = 0 + wordCount;
  let birdStage = 0;
  
  //A.) Global Word Count
  DOMstrings.wordCountValue.innerHTML = wordCount;

  //B.) Set a Bird Goal Count:
  if (birdCount == 0) {
    DOMstrings.birdExpValue.innerHTML = 0;

  } else if (birdCount < 100) {
    DOMstrings.birdExpValue.innerHTML = birdCount;

  } else if (wordCount >= 100 && wordCount < 400) {
      birdCount = (wordCount - 100);
      birdStage = 1;
      
      nextStage(alertStage[1])
      nextBird(birdStage);
      alertStage[1] = 0

      DOMstrings.birdExpValue.innerHTML = birdCount;
      DOMstrings.birdExpGoal.innerHTML = 300;

  } else if (wordCount >= 400 && wordCount < 1000) {
    birdCount = (wordCount - 400);
    birdStage = 2;

    nextStage(alertStage[2])
    nextBird(birdStage);
    alertStage[2] = 0

    DOMstrings.birdExpValue.innerHTML = birdCount;
    DOMstrings.birdExpGoal.innerHTML = 600;

  } else if (wordCount >= 1000) {
    birdStage = 3;

    nextStage(alertStage[3])
    nextBird(birdStage);
    alertStage[3] = 0

    DOMstrings.birdExpWords.innerHTML = "You've fully raised a bird!";
    DOMstrings.birdExpValue.innerHTML = "";
    DOMstrings.birdExpDivider.innerHTML = "";
    DOMstrings.birdExpGoal.innerHTML = "";

    console.log(birdStage);
  } else {
    alert("error");
  }
});

//3.) Display goal count
