A wakaba like imageboard on Rails 3.2 with a MongoDB

### Installation:

1. `bundle install`
2. setup your recaptcha keys in `config/initializers/recaptcha.rb` and configure your database in `config/mongoid.yml`
3. `bundle exec rails console`
4. `user = User.new(name: 'admin_name', role: 'adm', password: 'admin_pass')`
5. `user.save`
0. start your server
6. go to `yourboard.org/log_in` and log in with 'admin_name' and 'admin_pass'
7. create boards here: `yourboard.org/boards`
9000. add moderators here `yourboard.org/users`
8. ?????
9. PROFIT!

### Some screenshots:

#### Main page

![home](http://i.imgur.com/GpHaubg.png)

#### Board

![board](http://i.imgur.com/219YrJt.png)