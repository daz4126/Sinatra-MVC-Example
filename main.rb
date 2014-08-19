require 'sinatra'
require 'mongoid'
require 'slim'
require 'redcarpet'

configure do
  Mongoid.load!("./mongoid.yml")
end

# Model

class Note
  include Mongoid::Document
  field :title,   type: String
  field :content, type: String
end

# Controllers

get '/notes' do
  @notes = Note.all
  slim :index
end

get '/notes/new' do
  @note = Note.new
  slim :new
end

post '/notes' do
   if note = Note.create(params[:note])
    redirect to("/notes/#{note.id}")
   else
     slim :new 
   end
end

get '/notes/:id' do
  @note = Note.find(params[:id])
  slim :show
end

get '/notes/:id/edit' do
  @note = Note.find(params[:id])
  slim :edit
end

put '/notes/:id' do
  note = Note.find(params[:id])
  if note.update_attributes(params[:note])
    redirect to("/notes/#{note.id}")
  else
   slim :edit
 end
end

get '/notes/:id/delete' do
  @note = Note.find(params[:id])
  slim :delete
end

delete '/notes/:id' do
  Note.find(params[:id]).destroy
  redirect to('/notes')
end

__END__

#views

@@layout
doctype html
html
  head
    title Notes
    meta charset="utf-8"
  body
    nav
      ul
        li <a href="/notes">All Notes</a>
        li <a href="/notes/new">New Note</a>
    == yield

@@index
h1 Notes
-if @notes.any?
  ul.notes
    - @notes.each do |note|
      li <a href="/notes/#{note.id}">#{note.title}</a>
- else
  p No Notes have been created yet

@@show  
h1= @note.title
== markdown @note.content
ul
  li <a href="/notes/#{@note.id}/edit">EDIT</a>
  li <a href="/notes/#{@note.id}/delete">DELETE</a>
  
@@form
label for="title" Title:
input.title type="text" name="note[title]" value="#{@note.title}" size="32"
label for="content" Content:
textarea.content name="note[content]" rows="12" cols="72" ==@note.content

@@new
h1 New Note
form action="/notes" method="POST"
  fieldset
    legend Create New Note
    == slim :form
  input type="submit" value="Create"
  
@@edit
h1 Edit Note
form action="/notes/#{@note.id}" method="POST"
  input type="hidden" name="_method" value="PUT"
  fieldset
    legend Edit Note
    == slim :form
  input type="submit" value="Update"
  
@@delete
h1 Delete Note
p Are you sure you want to delete this note: #{@note.title}?
form action="/notes/#{@note.id}" method="POST"
  input type="hidden" name="_method" value="DELETE"
  input type="submit" value="Delete"
a href="/notes" cancel
