AddEventHandler('av_restaurant:drink', function(data)
    local job = data['job']
    local type = 'drink'
    lib.callback('av_restaurant:getItems', false, function(items)
        local menu = {}
        for k, v in pairs(items) do
            local ingredientsLabel = ""
            local ingredients = false
            if v['ingredients'] then
                ingredients = json.decode(v['ingredients'])
                for k, v in pairs(ingredients) do
                    if tonumber(k) == 1 then
                        ingredientsLabel = v
                    else
                        ingredientsLabel = ingredientsLabel.." | "..v
                    end
                end
            end
            menu[#menu+1] = {
                title = v['label'],
                description = "Ingredients: "..ingredientsLabel,
                event = "av_restaurant:craft",
                args = {
                    item = v['name'],
                    job = job,
                    type = type,
                    ingredients = ingredients,
                    image = v['image'],
                    itemLabel = v['label'],
                }
            }
        end
        lib.registerContext({
            id = 'av_restaurants:drink',
            title = Lang['drink'],
            options = menu,
        })
        lib.showContext('av_restaurants:drink')
    end,{job = job, type = type})
end)

