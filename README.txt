We only need one model for this project -- Datum.

After talking with the TAs, we decided that it would be best to add an entry for each API variable that is used. We have two columns: key and value. "Key" corresponds to the API variable, and "value" is the API query result formatted in JSON and cast to a string. We chose this model because it limits the amount of database lookups necessary. For any user-made query, we can grab the results from our database (if they're not there, fetch from API and update database) and filter out any states that the user may want.

As for validations, we just restrict that the key and value are always true. Both are necessary as we're basically keeping a dictionary. 

We are using only one controller. It is our "main" controller, to go with our "main" view. This is because we only need one page exposed to the user. Also, we only have one model so we didn't need additional controllers/views. We added this functionality (functionality to connect the controller to the view) now so that we can work on improving the view in the next iteration.