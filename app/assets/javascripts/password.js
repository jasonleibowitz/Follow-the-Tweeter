$( '.home.welcome' ).ready(function() {
  console.log('password loaded bro!');
  promptForPassword();
});

function promptForPassword(){
    var password = prompt('Follow the Tweeter is in beta. Please enter the password for access.', '');
    if (password === 'twitter baby') {
        $('.content').css("visibility", "visible");
    } else {
        alert("Incorrect password. Access Denied!");
    }
}
