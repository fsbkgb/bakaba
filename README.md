A wakaba like imageboard on Rails 3.2 with a MongoDB

### Installation:

1. `bundle install`
2. setup your recaptcha keys in `config/initializers/recaptcha.rb` and configure your database in `config/mongoid.yml`
3. (re)start your server
4. go to `yourboard.org/users` and create user with 'adm' role
5. comment out 4th line in `users_controller.rb`
0. restart your server
6. go to `yourboard.org/log_in` and log in as administrator
7. create categories and boards here: `yourboard.org/boards`
8. ?????
9. PROFIT!

### Some screenshots:

#### Main page

![home](http://i.imgur.com/GpHaubg.png)

#### Board

![board](http://i.imgur.com/219YrJt.png)