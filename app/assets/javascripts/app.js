$( document ).ready(function() {
    console.log( "loaded bro!" );
    $('#submit').click(showLoading);
    getGlobalChartVars();


    appendCanvasToDom();
    $(window).resize(reDrawChart);

    $('.tooltip').tooltipster({
        maxWidth: '500',
        position: 'bottom',
        animation: 'grow',
        iconTouch: true,
        onlyOne: true
    });
});

function appendCanvasToDom(){
    var dynamicWidth = ($(window).width() < 1300 && $(window).width() > 766)? $(window).width() * 0.50 : $(window).width() * 0.45;
    $('#canvas-wrap').prepend('<canvas id="myChart" height="' + dynamicWidth + '" width="' + dynamicWidth + '"></canvas>');
    drawChart();
}

function drawChart(){
    var options = {scaleShowGridLines: true};
    var ctx = $("#myChart").get(0).getContext("2d");
    // var myNewChart = new Chart(ctx);
    var myLineChart = new Chart(ctx).Line(data, options);
}

function getGlobalChartVars(){
    getLabels();
    getData();

    data = {
    labels: dates,
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(85, 172, 238, 0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: tweets
        }
      ]
    };
}

function reDrawChart(){
    $('#myChart').remove();
    appendCanvasToDom();
}

function getLabels(){
  dates = jQuery.parseJSON($('#tpd_keys').html());
}

function getData(){
  tweets = jQuery.parseJSON($('#tpd_values').html());
}

function showLoading(){
    $('#loading').css('visibility', 'visible');
}
