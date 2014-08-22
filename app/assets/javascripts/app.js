$( document ).ready(function() {
    console.log( "loaded bro!" );
    $('#submit').click(showLoading);
});

function showLoading(){
    $('#loading').css('visibility', 'visible');
}

