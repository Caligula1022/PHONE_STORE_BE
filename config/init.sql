CREATE TABLE public.cart
(
    id SERIAL NOT NULL,
    user_id integer UNIQUE NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE public.cart_item
(
    id SERIAL NOT NULL,
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (id),
    UNIQUE (cart_id, product_id)
);

CREATE TABLE public.order_item
(
    id SERIAL NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE TYPE "payment" AS ENUM (
  'PAYSTACK',
  'STRIPE'
);

CREATE TABLE public.orders
(
    order_id SERIAL NOT NULL,
    user_id integer NOT NULL,
    status character varying(20) NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    amount real,
    total integer,
    ref character varying(100),
    payment_method payment,
    PRIMARY KEY (order_id)
);
-- ### Added store table ######################
CREATE TABLE public.store
(
	store_id integer NOT NULL,
    store_name character varying(100) NOT NULL,
    region_id integer,
    PRIMARY KEY (store_id)
);

-- ### Added category and store_id ##########################
CREATE TABLE public.products
(
    product_id SERIAL NOT NULL,
    category category_type,
    name character varying(50) NOT NULL,
    price real NOT NULL,
    description text NOT NULL,
    image_url character varying,
    inventory integer CHECK (inventory>=0),
    PRIMARY KEY (product_id)
);

CREATE TYPE "category_type" AS ENUM (
  'Android',
  'iPhone'
);

-- ################### REGION TABLE #######################
CREATE TABLE public.region
(
region_id integer NOT NULL,
region_name character varying(100),
manager_id integer,
PRIMARY KEY(region_id)
);

-- ################### Manager TABLE #######################
CREATE TABLE public.manager
(
manager_id integer NOT NULL,
manager_name character varying(100),
store_id integer,
PRIMARY KEY(manager_id)
);


-- ################### Salesperson TABLE #######################
CREATE TABLE public.salesperson
(
sp_id integer NOT NULL,
sp_name character varying(100),
store_id integer,
PRIMARY KEY(sp_id)
);


CREATE TABLE public."resetTokens"
(
    id SERIAL NOT NULL,
    email character varying NOT NULL,
    token character varying NOT NULL,
    used boolean DEFAULT false NOT NULL,
    expiration timestamp without time zone,
    PRIMARY KEY (id)
);

CREATE TABLE public.reviews
(
    user_id integer NOT NULL,
    content text NOT NULL,
    rating integer NOT NULL,
    product_id integer NOT NULL,
    date date NOT NULL,
    id integer NOT NULL,
    PRIMARY KEY (user_id, product_id)
);

-- ## Added business as ENUM
CREATE TABLE public.users
(
    user_id SERIAL NOT NULL,
    password character varying(200),
    email character varying(100) UNIQUE NOT NULL,
    fullname character varying(100) NOT NULL,
    username character varying(50) UNIQUE NOT NULL,
    google_id character varying(100) UNIQUE,
    roles character varying(10)[] DEFAULT '{customer}'::character varying[] NOT NULL,
    address character varying(200),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    business business_type,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

CREATE TYPE "business_type" AS ENUM (
  'Student',
  'Retailer',
  'IT'
);
-- Ref:"customer"."user_id" < "cart"."user_id"
ALTER TABLE public.cart
    ADD FOREIGN KEY (user_id)
    REFERENCES public.users (user_id)
    ON DELETE SET NULL
    NOT VALID;

-- Ref:"cart"."id" < "cart_item"."cart_id"
ALTER TABLE public.cart_item
    ADD FOREIGN KEY (cart_id)
    REFERENCES public.cart (id)
    ON DELETE CASCADE
    NOT VALID;

-- Ref:"products"."product_id" < "cart_item"."product_id"
ALTER TABLE public.cart_item
    ADD FOREIGN KEY (product_id)
    REFERENCES public.products (product_id)
    ON DELETE SET NULL
    NOT VALID;

-- Ref:"orders"."order_id" < "order_item"."order_id"
ALTER TABLE public.order_item
    ADD FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id)
    ON DELETE CASCADE
    NOT VALID;

-- Ref:"products"."product_id" < "order_item"."product_id"
ALTER TABLE public.order_item
    ADD FOREIGN KEY (product_id)
    REFERENCES public.products (product_id)
    ON DELETE SET NULL
    NOT VALID;

-- Ref:"customer"."user_id" < "orders"."user_id"
ALTER TABLE public.orders
    ADD FOREIGN KEY (user_id)
    REFERENCES public.users (user_id)
    ON DELETE CASCADE
    NOT VALID;

-- Ref:"products"."product_id" < "reviews"."product_id"
ALTER TABLE public.reviews
    ADD FOREIGN KEY (product_id)
    REFERENCES public.products (product_id)
    ON DELETE SET NULL
    NOT VALID;

-- Ref:"customer"."user_id" < "reviews"."user_id"
ALTER TABLE public.reviews
    ADD FOREIGN KEY (user_id)
    REFERENCES public.users (user_id)
    ON DELETE SET NULL
    NOT VALID;
Ref:"store"."store_id" < "products"."store_id"
ALTER TABLE public.products
    ADD FOREIGN KEY (store_id)
    REFERENCES public.store (store_id)
    ON DELETE SET NULL
    NOT VALID;
Ref:"region"."region_id" < "store"."region_id"
ALTER TABLE public.store
    ADD FOREIGN KEY (region_id)
    REFERENCES public.region (region_id)
    ON DELETE SET NULL
    NOT VALID;
Ref:"manager"."manager_id" < "region"."manager_id"
ALTER TABLE public.region
    ADD FOREIGN KEY (manager_id)
    REFERENCES public.manager (manager_id)
    ON DELETE SET NULL
    NOT VALID;

Ref:"store"."store_id" < "salesperson"."store_id"
ALTER TABLE public.salesperson
    ADD FOREIGN KEY (store_id)
    REFERENCES public.store (store_id)
    ON DELETE SET NULL
    NOT VALID;

CREATE UNIQUE INDEX users_unique_lower_email_idx
    ON public.users (lower(email));

CREATE UNIQUE INDEX users_unique_lower_username_idx
    ON public.users (lower(username));

    -- Seed data for products table 
    -- product_id SERIAL NOT NULL,
    -- category category_type,
    -- name character varying(50) NOT NULL,
    -- price real NOT NULL,
    -- description text NOT NULL,
    -- image_url character varying,
    -- PRIMARY KEY (product_id)
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (1, 'iPhone','Swiss Cheese', 956.97, 'Swiss cheese is a mild cow''s milk cheese with a firmer texture than baby Swiss. The flavor is light, sweet, and nutty. Swiss cheese is distinguished by its luster, pale yellow color, and large holes (called eyes) caused by carbon dioxide released during the maturation process.', 'https://i.ibb.co/N16wJ48/swiss-cheese.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (2, 'iPhone','Pears', 759.19, 'Pears are rich in essential antioxidants, plant compounds, and dietary fiber. They pack all of these nutrients in a fat free, cholesterol free, 100 calorie package.', 'https://i.ibb.co/4fn5HJv/pear.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (12, 'iPhone','English Muffins', 979.29, 'A small, round, yeast-leavened sourdough bread that is commonly sliced horizontally, toasted, and buttered. In North America and Australia, it is commonly eaten for breakfast, often with sweet or savory toppings such as fruit jam or honey, or eggs, sausage, bacon, or cheese.', 'https://i.ibb.co/B6pr46Z/muffins.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (3, 'iPhone','Wasabi Paste', 669.45, 'Wasabi paste is spicy and pungent in flavour and is most commonly served with sushi and sashimi.', 'https://i.ibb.co/TB3vQy2/Wasabi-Paste.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (5, 'iPhone','Triple Sec-Mcguinness', 753.58, 'When mixed with your favorite cocktail, McGuinness Triple Sec becomes three times more delicious. The drink''s name means "dry" in French, and "triple" implies three times as dry, so it''s no surprise that people fall in love with this whisky flavor.', 'https://i.ibb.co/3TVtKHm/triple.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (9, 'iPhone','Apple Custard', 802.23, 'Custard apples have delicious mellow flesh that is almost as soft as custard. Custard apples are thought to have originated in South America and the West Indies. These apples are usually heart or oval in shape and can weigh up to 450g. They have quilted skin that is light tan or greenish in color and turns brown as the fruit ripens.', 'https://i.ibb.co/ctRZSqC/sugar-apple-custard-apple-sharifa-1.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (4, 'iPhone','Soup - Cambells Chicken', 707.1, 'You''ll enjoy serving delicious, nutritious Campbells Chicken Noodle Soup to your children. Kids love Campbells Chicken Noodle Soup because it has bite-sized chicken, slurpable noodles, and a warm, savory broth. 12 cans weighing 10.75 oz each. Cans with a condensed flavor and an easy-to-open pop top. It''s a quick and easy way to warm up mealtime for your kids at any time.', 'https://i.ibb.co/Vp9fw0F/campbell-chicken-soup.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (6,'iPhone','Sage Ground', 936.89, 'Sage is an excellent herb for seasoning fatty meats like pork, lamb, mutton, and game (goose or duck). It also complements onions, eggplant, tomatoes, and potatoes. Sage is frequently used in stuffings and cheeses.', 'https://i.ibb.co/B65SyN5/sage-ground.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (7, 'iPhone','Beef Consomme', 897.34, 'A sauce or soup base made from clarified meat stock (usually beef, veal, or poultry, but also fish) into a clear and flavorful liquid broth. Egg whites are used to clarify the meat stock as well as any additional ingredients such as vegetables and/or herbs. While the mixture is being brought to a boil, it is being stirred. The boiled solution is no longer stirred as the egg whites solidify on top of the mixture, allowing the fats and impurities to be absorbed or attached to the white.', 'https://i.ibb.co/Np4L8bs/beef-consomme.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (8, 'iPhone','Sausage Chorizo', 782.82, 'Chorizo is a highly seasoned chopped or ground pork sausage that is commonly found in Spanish and Mexican cuisine. Mexican chorizo is made from fresh (raw, uncooked) pork, whereas Spanish chorizo is typically smoked.', 'https://i.ibb.co/hXsSSCt/Sausage-Chorizo.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (10, 'iPhone','Bacardi Breezer', 890.29, 'The Bacardi Breezer is an excellent way to enjoy the world''s most popular rum – Bacardi. Bacardi Breezer Cranberry is a refreshing drink made from Bacardi rum, real cranberry juice, and carbonated water.', 'https://i.ibb.co/4f81wgz/bacardi.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (11, 'iPhone','Pita Bread', 935.72, 'A versatile flat bread that is soft and slightly chewy on the inside and often has a pocket inside as a result of baking the bread in a hot oven. Pita bread is frequently mistakenly thought to be unleavened, but it is usually leavened with yeast. The bread can be eaten plain or with a drizzle of olive oil.', 'https://i.ibb.co/G21ZsqY/Original-Pita-Bread-Front-1200x1200.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (13, 'iPhone','Mince - Meat FIlling', 611.56, 'Mincemeat is a combination of chopped dried fruit, distilled spirits, and spices, as well as occasionally beef suet, beef, or venison. Usually used as filling for mince pies during Christmas, but it tastes great mixed with vanilla ice cream, as well', 'https://i.ibb.co/mCMhF9N/meat-filling.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (14, 'iPhone','Pate - Cognac', 787.14, 'Pâté made with pork liver and meat that has been infused with cognac. The spirits complement the pâté''s rich, smooth flavor, which is sure to appeal to foodies.', 'https://i.ibb.co/8j9ghkk/Pate-Cognac.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (15, 'iPhone','Lamb Shoulder (Boneless)', 605, 'Great for roasts, stews or any lamb recipe that has a marinade or a long slow cooking time and temperature.', 'https://i.ibb.co/h9Bm7nP/lamb-shoulder.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (16, 'iPhone','Icecream - Dark Super Cone', 867.05, 'Natural flavors, colors, and fragrances Contains no peanuts or nuts. 4 cones of French Vanilla ice cream and 4 cones of Dark Chocolate ice cream with a thick dark chocolate core These Super Cones are made with 100% Canadian dairy and are wrapped in dark chocolate sugar cones with a chocolate topping. A fantastic flavor offering in a great family package.
Delectables for a single serving
Produced in a peanut and nut-free environment.', 'https://i.ibb.co/KXqcnsG/icecream.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (17, 'iPhone','Puree Raspberry', 717.68, 'Make the perfect summer sorbet to cool off in style! This 100% natural frozen puree is made of 90% fruit and 10% sugar, with no artificial flavors, colorings, or preservatives: simple, fresh, and delicious! Make sorbets, smoothies, ice creams, jellies and jams, sauces, and pastry fillings with this raspberry puree.', 'https://i.ibb.co/1LX9RMw/puree-raspberry.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (18, 'iPhone','Black Currant Jelly', 898.42, 'The natural flavor of the fruit is preserved by gently cooking in the French countryside tradition.
Sweetened only with vineyard ripened grape and fruit juices, 100 percent from fruit Authentic French Recipe, Gently cooked to preserve the natural flavor of the fruit, Gluten-Free, Only Natural Sugars, Non-Genetically Modified Ingredients, No Cane Sugars, Corn Syrups, Artificial Sweeteners, Colors, Flavors, or Preservatives, All Natural Ingredients', 'https://i.ibb.co/znrFfPt/jam.jpg', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (19, 'iPhone','Rice - 7 Grain Blend', 732.36, 'Rice with a brown hue. Barley. Millet. Flax seed is a type of seed. Wheat. Quinoa in a red color. Rice from the wild. Microwave for 90 seconds in the pouch. USDA certified organic. 100% Whole Grain: 44 g or more per serving Consume 48 g or more of whole grains per day. You''re only 90 seconds away from a nutritious side dish or a meal on its own. It''s that easy!', 'https://i.ibb.co/Srv1Hjr/rice.png', 0);
INSERT INTO public.products (product_id, category, name, price, description, image_url, invertory) VALUES (20, 'iPhone','Saskatoon Berries - Frozen', 606.2, 'Raw plant-based superfood jam-packed with nutrients to get you through the day! We can keep all of the benefits and flavors of fresh Saskatoon Berries by freeze drying them, making them an easy on-the-go treat! They''re great as a healthy snack or added to cereals, smoothies, salads, and baking. A healthy diet high in vegetables and fruits may lower the risk of certain types of cancer.', 'https://i.ibb.co/ZcPjq1Y/berry.png', 0);




