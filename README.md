## mastermind-api

This is a verry simple API for [bulls and cows](http://en.wikipedia.org/wiki/Bulls_and_cows) game a.k.a [mastermind](http://en.wikipedia.org/wiki/Mastermind_%28board_game%29)
with numbers.

### How to use this?

Clone the repository:
```
% git clone git@github.com:radubogdan/mastermind-api.git
```

Make sure you have everything from Gemfile
```
% bundle
```

Create the database and migrate it:
```
% rake db:create && rake db:migrate
```

Start the WEBrick server:
```
% rails s
```

If you have a server, there is a deploy.rb file in config/ where you have to change credentials and deploy the application using mina. Also, in production
I configured this with [Unicorn](http://unicorn.bogomips.org/).

Feel free to change everything you want. You can contribute to this using Fork and Pull Request.

### API Calls

After you start the server on localhost, to start a new game, make a GET request at: ```/api/games/new```
To submit a guess, make POST request a ```/api/games/``` with following parameters:

* guess - the user input
* game_token - this is to recognize the game. It's a UUID
* name - this is optional, you can send this only once.

Responses are json objects.

Example:
Init a new game: ``` curl -X GET http://localhost:3000/api/games/new ```
Respose: ``` {"mastermind":{"game_token":"a1ba76a1-9921-4932-b391-cb4be016c39a"}} ```

What's in the database: ```select * from games;```

```

id | number |              game_token              | name | tries |        created_at         |        updated_at
----+--------+--------------------------------------+------+-------+---------------------------+---------------------------
 1 |   1854 | a1ba76a1-9921-4932-b391-cb4be016c39a |      |     0 | 2014-01-06 14:48:25.95643 | 2014-01-06 14:48:25.95643
 (1 row)

```
Make a guess: ``` curl -X POST http://localhost:3000/api/games -F "game_token=a1ba76a1-9921-4932-b391-cb4be016c39a" -F "guess=1234" ```
Response: ```{"mastermind":{"bulls":2,"cows":0,"tries":1}}```

After you guess the number, to mark a complete game, number will be deleted:
Make a guess: ``` curl -X POST http://localhost:3000/api/games -F "game_token=a1ba76a1-9921-4932-b391-cb4be016c39a" -F "guess=1854 -F "name=Radu" ```
Response: ``` {"mastermind":{"bulls":4,"cows":0,"tries":2}} ```
Database: 

```

id | number |              game_token              | name | tries |         created_at         |         updated_at
----+--------+--------------------------------------+------+-------+----------------------------+----------------------------
 1 |        | a1ba76a1-9921-4932-b391-cb4be016c39a | Radu |     2 | 2014-01-06 14:48:25.95643  | 2014-01-06 14:53:59.553585
 (1 rows)

```

### Jquery Example 
```
var start = function(){
    var mastermindApi = 'http://localhost:3000/api/games/new';

    $.getJSON(mastermindApi, function(data) {
        $('#game_token').val(data.mastermind.game_token);
    });
};

```

```
$("#send").on("click", function() {
    var mastermindApi = 'http://localhost:3000/api/games/';
    var guess = $('#req').val();
    var token = $('#game_token').val();

    if (guess.length === 4){
        $.post(mastermindApi, { guess : guess, game_token : token }).done(function(data) {
            var format_result = guess + " " + data.mastermind.bulls + " " + data.mastermind.cows;

            $('.gueses').append("<li>" + format_result + "</li>");

            if (data.mastermind.bulls === 4) {
                $('.gueses').append("<li>" + "Congratulations! You have guessed the number in " + data.mastermind.tries + " tries" + "</li>");
            }

        });
    }

    return false;
});
```

### Authors
[Radu-Bogdan Croitoru](https://github.com/radubogdan)
[George Bejan](https://github.com/georgebejan)

### License
See [License](https://github.com/radubogdan/mastermind-api/blob/master/LICENSE)
