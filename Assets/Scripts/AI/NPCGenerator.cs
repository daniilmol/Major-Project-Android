using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class NPCGenerator : MonoBehaviour
{
    [SerializeField] GameObject meoplePrefab;
    [SerializeField] int maxMeoples;
    [SerializeField][Range(0, 100)] int singleChance;
    [SerializeField][Range(0, 100)] int singleParentChance;
    [SerializeField][Range(0, 100)] int kidChance;
    [SerializeField][Range(1, 10)] int maxKids;
    private int createdMeoples;
    private float x;
    private string[] femaleNames = {"Emily","Hannah","Madison","Ashley","Sarah","Alexis","Samantha","Jessica","Elizabeth","Taylor","Lauren","Alyssa","Kayla","Abigail","Brianna",
    "Olivia","Emma","Megan","Grace","Victoria","Rachel","Anna","Sydney","Destiny","Morgan","Jennifer","Jasmine","Haley","Julia","Kaitlyn","Nicole","Amanda","Katherine","Natalie",
    "Hailey","Alexandra","Savannah","Chloe","Rebecca","Stephanie","Maria","Sophia","Mackenzie","Allison","Isabella","Amber","Mary","Danielle","Gabrielle","Jordan","Brooke",
    "Michelle","Sierra","Katelyn","Andrea","Madeline","Sara","Kimberly","Courtney","Erin","Brittany","Vanessa","Jenna","Jacqueline","Caroline","Faith","Makayla","Bailey","Paige",
    "Shelby","Melissa","Kaylee","Christina","Trinity","Mariah","Caitlin","Autumn","Marissa","Breanna","Angela","Catherine","Zoe","Briana","Jada","Laura","Claire","Alexa","Kelsey",
    "Kathryn","Leslie","Alexandria","Sabrina","Mia","Isabel","Molly","Leah","Katie","Gabriella","Cheyenne","Cassandra","Tiffany","Erica","Lindsey","Kylie","Amy","Diana","Cassidy",
    "Mikayla","Ariana","Margaret","Kelly","Miranda","Maya","Melanie","Audrey","Jade","Gabriela","Caitlyn","Angel","Jillian","Alicia","Jocelyn","Erika","Lily","Heather","Madelyn",
    "Adriana","Arianna","Lillian","Kiara","Riley","Crystal","Mckenzie","Meghan","Skylar","Ana","Britney","Angelica","Kennedy","Chelsea","Daisy","Kristen","Veronica","Isabelle",
    "Summer","Hope","Brittney","Lydia","Hayley","Evelyn","Bethany","Shannon","Michaela","Karen","Jamie","Daniela","Angelina","Kaitlin","Karina","Sophie","Sofia","Diamond","Payton",
    "Cynthia","Alexia","Valerie","Monica","Peyton","Carly","Bianca","Hanna","Brenda","Rebekah","Alejandra","Mya","Avery","Brooklyn","Ashlyn","Lindsay","Ava","Desiree","Alondra",
    "Camryn","Ariel","Naomi","Jordyn","Kendra","Mckenna","Holly","Julie","Kendall","Kara","Jasmin","Selena","Esmeralda","Amaya","Kylee","Maggie","Makenzie","Claudia","Kyra",
    "Cameron","Karla","Kathleen","Abby","Delaney","Amelia","Casey","Serena","Savanna","Aaliyah","Giselle","Mallory","April","Raven","Adrianna","Christine","Kristina","Nina",
    "Asia","Natalia","Valeria","Aubrey","Lauryn","Kate","Patricia","Jazmin","Rachael","Katelynn","Cierra","Alison","Macy","Nancy","Elena","Kyla","Katrina","Jazmine","Joanna",
    "Tara","Gianna","Juliana","Fatima","Allyson","Gracie","Sadie","Guadalupe","Genesis","Yesenia","Julianna","Skyler","Tatiana","Alexus","Alana","Elise","Kirsten","Nadia","Sandra"
    ,"Dominique","Ruby","Haylee","Jayla","Tori","Cindy","Sidney","Ella","Tessa","Carolina","Camille","Jaqueline","Whitney","Carmen","Vivian","Priscilla","Bridget","Celeste",
    "Kiana","Makenna","Alissa","Madeleine","Miriam","Natasha","Ciara","Cecilia","Mercedes","Kassandra","Reagan","Aliyah","Josephine","Charlotte","Rylee","Shania","Kira","Meredith",
    "Eva","Lisa","Dakota","Hallie","Anne","Rose","Liliana","Kristin","Deanna","Imani","Marisa","Kailey","Annie","Nia","Carolyn","Anastasia","Brenna","Dana","Shayla","Ashlee",
    "Kassidy","Alaina","Rosa","Wendy","Logan","Tabitha","Paola","Callie","Addison","Lucy","Gillian","Clarissa","Destinee","Josie","Esther","Denise","Katlyn","Mariana","Bryanna",
    "Emilee","Georgia","Deja","Kamryn","Ashleigh","Cristina","Baylee","Heaven","Ruth","Raquel","Monique","Teresa","Helen","Krystal","Tiana","Cassie","Kayleigh","Marina","Heidi",
    "Ivy","Ashton","Clara","Meagan","Gina","Linda","Gloria","Jacquelyn","Ellie","Jenny","Renee","Daniella","Lizbeth","Anahi","Virginia","Gisselle","Kaitlynn","Julissa","Cheyanne",
    "Lacey","Haleigh","Marie","Martha","Eleanor","Kierra","Tiara","Talia","Eliza","Kaylie","Mikaela","Harley","Jaden","Hailee","Madalyn","Kasey","Ashlynn","Brandi","Lesly",
    "Elisabeth","Allie","Viviana","Cara","Marisol","India","Tatyana","Litzy","Melody","Jessie","Brandy","Alisha","Hunter","Noelle","Carla","Francesca","Tia","Layla","Krista",
    "Zoey","Carley","Janet","Carissa","Iris","Kaleigh","Tyler","Susan","Tamara","Theresa","Yasmine","Tatum","Sharon","Alice","Yasmin","Tamia","Abbey","Alayna","Kali","Lilly",
    "Bailee","Lesley","Mckayla","Ayanna","Serenity","Karissa","Precious","Jane","Maddison","Jayda","Kelsie","Lexi","Phoebe","Halle","Kiersten","Kiera","Tyra","Annika","Felicity",
    "Taryn","Kaylin","Ellen","Kiley","Jaclyn","Rhiannon","Madisyn","Colleen","Joy","Pamela","Charity","Tania","Fiona","Alyson","Kaila","Annabelle","Emely","Angelique","Alina"
    ,"Irene","Johanna","Regan","Janelle","Janae","Madyson","Paris","Justine","Chelsey","Sasha","Paulina","Mayra","Zaria","Skye","Cora","Brisa","Emilie","Felicia","Larissa",
    "Macie","Tianna","Aurora","Sage","Lucia","Alma","Chasity","Ann","Deborah","Nichole","Jayden","Alanna","Malia","Carlie","Angie","Nora","Kailee","Sylvia","Carrie","Elaina",
    "Sonia","Genevieve","Kenya","Piper","Marilyn","Amari","Macey","Marlene","Barbara","Tayler","Julianne","Brooklynn","Lorena","Perla","Elisa","Kaley","Leilani","Eden","Miracle",
    "Devin","Aileen","Chyna","Athena","Esperanza","Regina","Adrienne","Shyanne","Luz","Tierra","Cristal","Clare","Eliana","Kelli","Eve","Sydnee","Madelynn","Breana","Melina",
    "Arielle","Justice","Toni","Corinne","Maia","Tess","Abbigail","Ciera","Ebony","Maritza","Lena","Lexie","Isis","Aimee","Leticia","Sydni","Sarai","Halie","Alivia","Destiney",
    "Laurel","Edith","Carina","Fernanda","Amya","Destini","Aspen","Nathalie","Paula","Tanya","Frances","Tina","Christian","Elaine","Shayna","Aniya","Mollie","Ryan","Essence",
    "Simone","Kyleigh","Nikki","Anya","Reyna","Kaylyn","Nicolette","Savanah","Abbie","Montana","Kailyn","Itzel","Leila","Cayla","Stacy","Araceli","Robin","Dulce","Candace","Noemi",
    "Jewel","Aleah","Ally","Mara","Nayeli","Karlee","Keely","Alisa","Micaela","Desirae","Leanna","Antonia","Brynn","Jaelyn","Judith","Raegan","Katelin","Sienna","Celia","Yvette"
    ,"Juliet","Anika","Emilia","Calista","Carlee","Eileen","Kianna","Thalia","Rylie","Daphne","Kacie","Karli","Rosemary","Ericka","Jadyn","Lyndsey","Micah","Hana","Haylie",
    "Madilyn","Laila","Blanca","Kayley","Katarina","Kellie","Maribel","Sandy","Joselyn","Kaelyn","Madisen","Carson","Kathy","Margarita","Stella","Juliette","Devon","Camila",
    "Bria","Donna","Helena","Lea","Jazlyn","Jazmyn","Skyla","Christy","Katharine","Joyce","Karlie","Lexus","Salma","Alessandra","Delilah","Moriah","Celine","Lizeth","Beatriz",
    "Brianne","Kourtney","Sydnie","Stacey","Mariam","Robyn","Hayden","Janessa","Kenzie","Jalyn","Sheila","Meaghan","Aisha","Jaida","Shawna","Estrella","Marley","Melinda","Ayana",
    "Karly","Devyn","Nataly","Loren","Rosalinda","Brielle","Laney","Lizette","Sally","Tracy","Lilian","Rebeca","Chandler","Jenifer","Valentina","America","Candice","Diane",
    "Abigayle","Susana","Aliya","Casandra","Harmony","Jacey","Alena","Aylin","Carol","Shea","Stephany","Aniyah","Zoie","Jackeline","Alia","Savana","Damaris","Gwendolyn","Violet",
    "Marian","Anita","Jaime","Alexandrea","Jaiden","Kristine","Carli","Dorothy","Gretchen","Janice","Annette","Mariela","Amani","Maura","Bella","Kaylynn","Lila","Armani","Anissa",
    "Aubree","Kelsi","Greta","Kaya","Kayli","Lillie","Willow","Ansley","Catalina","Lia","Maci","Celina","Shyann","Alysa","Jaquelin","Kasandra","Quinn","Cecelia","Mattie","Chaya",
    "Hailie","Haven","Kallie","Maegan","Maeve","Rocio","Yolanda","Christa","Gabriel","Kari","Noelia","Jeanette","Kaylah","Marianna","Nya","Kennedi","Presley","Yadira","Elissa",
    "Nyah","Reilly","Shaina","Alize","Arlene","Amara","Izabella","Lyric","Aiyana","Allyssa","Drew","Rachelle","Adeline","Jacklyn","Jesse","Citlalli","Liana","Giovanna","Princess"
    ,"Selina","Brook","Elyse","Graciela","Cali","Berenice","Chanel","Iliana","Jolie","Caitlynn","Christiana","Annalise","Cortney","Darlene","Sarina","Dasia","London","Yvonne",
    "Karley","Shaylee","Myah","Amira","Juanita","Kristy","Ryleigh","Dariana","Teagan","Kiarra","Ryann","Yamilet","Alexys","Kacey","Shakira","Sheridan","Baby","Dianna","Lara",
    "Isabela","Reina","Shirley","Jaycee","Silvia","Tatianna","Eryn","Ingrid","Keara","Randi","Reanna","Kalyn","Lisette","Monserrat","Lori","Abril","Ivana","Kaela","Maranda"};
    private string[] maleNames = {"Jacob","Michael","Matthew","Joshua","Christopher","Nicholas","Andrew","Joseph","Daniel","Tyler","William","Brandon","Ryan","John","Zachary",
    "David","Anthony","James","Justin","Alexander","Jonathan","Christian","Austin","Dylan","Ethan","Benjamin","Noah","Samuel","Robert","Nathan","Cameron","Kevin","Thomas","Jose"
    ,"Hunter","Jordan","Kyle","Caleb","Jason","Logan","Aaron","Eric","Brian","Gabriel","Adam","Jack","Isaiah","Juan","Luis","Connor","Charles","Elijah","Isaac","Steven","Evan",
    "Jared","Sean","Timothy","Luke","Cody","Nathaniel","Alex","Seth","Mason","Richard","Carlos","Angel","Patrick","Devin","Bryan","Cole","Jackson","Ian","Garrett","Trevor","Jesus"
    ,"Chase","Adrian","Mark","Blake","Sebastian","Antonio","Lucas","Jeremy","Gavin","Miguel","Julian","Dakota","Alejandro","Jesse","Dalton","Bryce","Tanner","Kenneth","Stephen",
    "Jake","Victor","Spencer","Marcus","Paul","Brendan","Jeremiah","Xavier","Jeffrey","Tristan","Jalen","Jorge","Edward","Riley","Wyatt","Colton","Joel","Maxwell","Aidan","Travis"
    ,"Shane","Colin","Dominic","Carson","Vincent","Derek","Oscar","Grant","Eduardo","Peter","Henry","Parker","Hayden","Collin","George","Bradley","Mitchell","Devon","Ricardo",
    "Shawn","Taylor","Nicolas","Francisco","Gregory","Liam","Kaleb","Preston","Erik","Alexis","Owen","Omar","Diego","Dustin","Corey","Fernando","Clayton","Carter","Ivan","Jaden"
    ,"Javier","Alec","Johnathan","Scott","Manuel","Cristian","Alan","Raymond","Brett","Max","Andres","Gage","Mario","Dawson","Dillon","Cesar","Wesley","Levi","Jakob","Chandler",
    "Martin","Malik","Edgar","Trenton","Sergio","Josiah","Nolan","Marco","Peyton","Harrison","Hector","Micah","Roberto","Drew","Brady","Erick","Conner","Jonah","Casey","Jayden"
    ,"Emmanuel","Edwin","Andre","Phillip","Brayden","Landon","Giovanni","Bailey","Ronald","Braden","Damian","Donovan","Ruben","Frank","Pedro","Gerardo","Andy","Chance","Abraham"
    ,"Calvin","Trey","Cade","Donald","Derrick","Payton","Darius","Enrique","Keith","Raul","Jaylen","Troy","Jonathon","Cory","Marc","Skyler","Rafael","Trent","Griffin","Colby",
    "Johnny","Eli","Chad","Armando","Kobe","Caden","Cooper","Marcos","Elias","Brenden","Israel","Avery","Zane","Dante","Josue","Zackary","Allen","Mathew","Dennis","Leonardo",
    "Ashton","Philip","Julio","Miles","Damien","Ty","Gustavo","Drake","Jaime","Simon","Jerry","Curtis","Kameron","Lance","Brock","Bryson","Alberto","Dominick","Jimmy","Kaden",
    "Douglas","Gary","Brennan","Zachery","Randy","Louis","Larry","Nickolas","Tony","Albert","Fabian","Keegan","Saul","Danny","Tucker","Damon","Myles","Arturo","Corbin","Deandre"
    ,"Ricky","Kristopher","Lane","Pablo","Darren","Zion","Jarrett","Alfredo","Micheal","Angelo","Carl","Oliver","Kyler","Tommy","Walter","Dallas","Jace","Quinn","Theodore",
    "Grayson","Lorenzo","Joe","Arthur","Bryant","Brent","Roman","Russell","Ramon","Lawrence","Moises","Aiden","Quentin","Tyrese","Jay","Tristen","Emanuel","Salvador","Terry",
    "Morgan","Jeffery","Esteban","Tyson","Braxton","Branden","Brody","Craig","Marvin","Ismael","Rodney","Isiah","Maurice","Marshall","Ernesto","Emilio","Brendon","Kody","Eddie",
    "Malachi","Abel","Keaton","Jon","Shaun","Skylar","Nikolas","Ezekiel","Santiago","Kendall","Axel","Camden","Trevon","Bobby","Conor","Jamal","Lukas","Malcolm","Zackery","Jayson"
    ,"Javon","Reginald","Zachariah","Desmond","Roger","Felix","Dean","Johnathon","Quinton","Ali","Davis","Gerald","Demetrius","Rodrigo","Billy","Rene","Reece","Justice","Kelvin",
    "Leo","Guillermo","Chris","Kevon","Steve","Frederick","Clay","Weston","Dorian","Hugo","Orlando","Roy","Terrance","Kai","Khalil","Graham","Noel","Nathanael","Willie","Terrell"
    ,"Tyrone","Camron","Mauricio","Amir","Darian","Jarod","Nelson","Kade","Reese","Kristian","Garret","Marquis","Rodolfo","Dane","Felipe","Todd","Elian","Walker","Mateo","Jaylon",
    "Kenny","Bruce","Ezra","Ross","Damion","Francis","Tate","Byron","Reid","Warren","Randall","Bennett","Jermaine","Triston","Jaquan","Harley","Jessie","Franklin","Duncan"
    ,"Charlie","Reed","Blaine","Braeden","Holden","Ahmad","Issac","Kendrick","Melvin","Sawyer","Solomon","Moses","Jaylin","Sam","Cedric","Mohammad","Alvin","Beau","Jordon",
    "Elliot","Lee","Darrell","Jarred","Mohamed","Davion","Wade","Tomas","Jaxon","Uriel","Deven","Maximilian","Rogelio","Gilberto","Ronnie","Julius","Allan","Brayan","Deshawn"
    ,"Joey","Terrence","Noe","Alfonso","Ahmed","Tyree","Tyrell","Jerome","Devan","Neil","Ramiro","Pierce","Davon","Devonte","Jamie","Leon","Adan","Eugene","Stanley","Marlon",
    "Quincy","Leonard","Wayne","Will","Alvaro","Ernest","Harry","Addison","Ray","Alonzo","Jadon","Jonas","Keyshawn","Rolando","Mohammed","Tristin","Donte","Dominique","Leonel"
    ,"Wilson","Gilbert","Coby","Dangelo","Kieran","Colten","Keenan","Koby","Jarrod","Dale","Harold","Toby","Dwayne","Elliott","Osvaldo","Cyrus","Kolby","Sage","Coleman","Declan",
    "Adolfo","Ariel","Brennen","Darryl","Trace","Orion","Shamar","Efrain","Keshawn","Rudy","Ulises","Darien","Braydon","Ben","Vicente","Nasir","Dayton","Joaquin","Karl","Dandre",
    "Isaias","Rylan","Sterling","Cullen","Quintin","Stefan","Brice","Lewis","Gunnar","Humberto","Nigel","Alfred","Agustin","Asher","Daquan","Easton","Salvatore","Jaron","Nathanial"
    ,"Ralph","Everett","Hudson","Marquise","Tobias","Glenn","Antoine","Jasper","Elvis","Kane","Sidney","Ezequiel","Tylor","Aron","Dashawn","Devyn","Mike","Silas","Jaiden","Jayce",
    "Deonte","Romeo","Deon","Cristopher","Freddy","Kurt","Kolton","River","August","Roderick","Clarence","Derick","Jamar","Raphael","Rohan","Kareem","Muhammad","Demarcus","Sheldon"
    ,"Markus","Cayden","Luca","Tre","Jamison","Jean","Rory","Brad","Clinton","Jaylan","Titus","Emiliano","Jevon","Julien","Alonso","Lamar","Cordell","Gordon","Ignacio","Jett",
    "Keon","Baby","Cruz","Rashad","Tariq","Armani","Deangelo","Milton","Geoffrey","Elisha","Moshe","Bernard","Asa","Bret","Darion","Darnell","Izaiah","Irvin","Jairo","Howard",
    "Aldo","Zechariah","Ayden","Garrison","Norman","Stuart","Kellen","Travon","Shemar","Dillan","Junior","Darrius","Rhett","Barry","Kamron","Jude","Rigoberto","Amari","Jovan",
    "Octavio","Perry","Kole","Misael","Hassan","Jaren","Latrell","Roland","Quinten","Ibrahim","Justus","German","Gonzalo","Nehemiah","Forrest","Mackenzie","Anton","Chaz","Talon"
    ,"Guadalupe","Austen","Brooks","Conrad","Greyson","Winston","Antwan","Dion","Lincoln","Leroy","Earl","Jaydon","Landen","Gunner","Brenton","Jefferson","Fredrick","Kurtis",
    "Maximillian","Stephan","Stone","Shannon","Shayne","Karson","Stephon","Nestor","Frankie","Gianni","Keagan","Tristian","Dimitri","Kory","Zakary","Donavan","Draven","Jameson",
    "Clifton","Daryl","Emmett","Cortez","Destin","Jamari","Dallin","Estevan","Grady","Davin","Santos","Marcel","Carlton","Dylon","Mitchel","Clifford","Syed","Adonis","Dexter",
    "Keyon","Reynaldo","Devante","Arnold","Clark","Kasey","Sammy","Thaddeus","Glen","Jarvis","Garett","Infant","Keanu","Kenyon","Nick","Ulysses","Dwight","Kent","Denzel","Lamont"
    ,"Houston","Layne","Darin","Jorden","Anderson","Kayden","Khalid","Antony","Deondre","Ellis","Marquez","Ari","Cornelius","Austyn","Brycen","Abram","Remington","Braedon","Reuben"};
    private string[] lastNames = {"Smith","Johnson","Williams","Brown","Jones","Miller","Davis","Garcia","Rodriguez","Wilson","Martinez","Anderson","Taylor","Thomas","Hernandez",
    "Moore","Martin","Jackson","Thompson","White","Lopez","Lee","Gonzalez","Harris","Clark","Lewis","Robinson","Walker","Perez","Hall","Young","Allen","Sanchez","Wright","King",
    "Scott","Green","Baker","Adams","Nelson","Hill","Ramirez","Campbell","Mitchell","Roberts","Carter","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart"
    ,"Flores","Morris","Nguyen","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson",
    "Wood","Watson","Brooks","Bennett","Gray","James","Reyes","Cruz","Hughes","Price","Myers","Long","Foster","Sanders","Ross","Morales","Powell","Sullivan","Russell","Ortiz",
    "Jenkins","Gutierrez","Perry","Butler","Barnes","Fisher","Henderson","Coleman","Simmons","Patterson","Jordan","Reynolds","Hamilton","Graham","Kim","Gonzales","Alexander",
    "Ramos","Wallace","Griffin","West","Cole","Hayes","Chavez","Gibson","Bryant","Ellis","Stevens","Murray","Ford","Marshall","Owens","McDonald","Harrison","Ruiz","Kennedy",
    "Wells","Alvarez","Woods","Mendoza","Castillo","Olson","Webb","Washington","Tucker","Freeman","Burns","Henry","Vasquez","Snyder","Simpson","Crawford","Jimenez","Porter",
    "Mason","Shaw","Gordon","Wagner","Hunter","Romero","Hicks","Dixon","Hunt","Palmer","Robertson","Black","Holmes","Stone","Meyer","Boyd","Mills","Warren","Fox","Rose","Rice",
    "Moreno","Schmidt","Patel","Ferguson","Nichols","Herrera","Medina","Ryan","Fernandez","Weaver","Daniels","Stephens","Gardner","Payne","Kelley","Dunn","Pierce","Arnold","Tran"
    ,"Spencer","Peters","Hawkins","Grant","Hansen","Castro","Hoffman","Hart","Elliott","Cunningham","Knight","Bradley","Carroll","Hudson","Duncan","Armstrong","Berry","Andrews",
    "Johnston","Ray","Lane","Riley","Carpenter","Perkins","Aguilar","Silva","Richards","Willis","Matthews","Chapman","Lawrence","Garza","Vargas","Watkins","Wheeler","Larson",
    "Carlson","Harper","George","Greene","Burke","Guzman","Morrison","Munoz","Jacobs","Brien","Lawson","Franklin","Lynch","Bishop","Carr","Salazar","Austin","Mendez","Gilbert",
    "Jensen","Williamson","Montgomery","Harvey","Oliver","Howell","Dean","Hanson","Weber","Garrett","Sims","Burton","Fuller","Soto","McCoy","Welch","Chen","Schultz","Walters",
    "Reid","Fields","Walsh","Little","Fowler","Bowman","Davidson","May","Day","Schneider","Newman","Brewer","Lucas","Holland","Wong","Banks","Santos","Curtis","Pearson","Delgado",
    "Valdez","Pena","Rios","Douglas","Sandoval","Barrett","Hopkins","Keller","Guerrero","Stanley","Bates","Alvarado","Beck","Ortega","Wade","Estrada","Contreras","Barnett",
    "Caldwell","Santiago","Lambert","Powers","Chambers","Nunez","Craig","Leonard","Lowe","Rhodes","Byrd","Gregory","Shelton","Frazier","Becker","Maldonado","Fleming","Vega",
    "Sutton","Cohen","Jennings","Parks","McDaniel","Watts","Barker","Norris","Vaughn","Vazquez","Holt","Schwartz","Steele","Benson","Neal","Dominguez","Horton","Terry","Wolfe"
    ,"Hale","Lyons","Graves","Haynes","Miles","Park","Warner","Padilla","Bush","Thornton","McCarthy","Mann","Zimmerman","Erickson","Fletcher","McKinney","Page","Dawson","Joseph",
    "Marquez","Reeves","Klein","Espinoza","Baldwin","Moran","Love","Robbins","Higgins","Ball","Cortez","Le","Griffith","Bowen","Sharp","Cummings","Ramsey","Hardy","Swanson",
    "Barber","Acosta","Luna","Chandler","Blair","Daniel","Cross","Simon","Dennis","Connor","Quinn","Gross","Navarro","Moss","Fitzgerald","Doyle","McLaughlin","Rojas","Rodgers"
    ,"Stevenson","Singh","Yang","Figueroa","Harmon","Newton","Paul","Manning","Garner","McGee","Reese","Francis","Burgess","Adkins","Goodman","Curry","Brady","Christensen",
    "Potter","Walton","Goodwin","Mullins","Molina","Webster","Fischer","Campos","Avila","Sherman","Todd","Chang","Blake","Malone","Wolf","Hodges","Juarez","Gill","Farmer","Hines"
    ,"Gallagher","Duran","Hubbard","Cannon","Miranda","Wang","Saunders","Tate","Mack","Hammond","Carrillo","Townsend","Wise","Ingram","Barton","Mejia","Ayala","Schroeder",
    "Hampton","Rowe","Parsons","Frank","Waters","Strickland","Osborne","Maxwell","Chan","Deleon","Norman","Harrington","Casey","Patton","Logan","Bowers","Mueller","Glover",
    "Floyd","Hartman","Buchanan","Cobb","French","Kramer","McCormick","Clarke","Tyler","Gibbs","Moody","Conner","Sparks","McGuire","Leon","Bauer","Norton","Pope","Flynn","Hogan",
    "Robles","Salinas","Yates","Lindsey","Lloyd","Marsh","McBride","Owen","Solis","Pham","Lang","Pratt","Lara","Brock","Ballard","Trujillo","Shaffer","Drake","Roman","Aguirre",
    "Morton","Stokes","Lamb","Pacheco","Patrick","Cochran","Shepherd","Cain","Burnett","Hess","Li","Cervantes","Olsen","Briggs","Ochoa","Cabrera","Velasquez","Montoya","Roth",
    "Meyers","Cardenas","Fuentes","Weiss","Hoover","Wilkins","Nicholson","Underwood","Short","Carson","Morrow","Colon","Holloway","Summers","Bryan","Petersen","Mckenzie","Serrano"
    ,"Wilcox","Carey","Clayton","Poole","Calderon","Gallegos","Greer","Rivas","Guerra","Decker","Collier","Wall","Whitaker","Bass","Flowers","Davenport","Conley","Houston","Huff",
    "Copeland","Hood","Monroe","Massey","Roberson","Combs","Franco","Larsen","Pittman","Randall","Skinner","Wilkinson","Kirby","Cameron","Bridges","Anthony","Richard","Kirk",
    "Bruce","Singleton","Mathis","Bradford","Boone","Abbott","Charles","Allison","Sweeney","Atkinson","Horn","Jefferson","Rosales","York","Christian","Phelps","Farrell","Castaneda"
    ,"Nash","Dickerson","Bond","Wyatt","Foley","Chase","Gates","Vincent","Mathews","Hodge","Garrison","Trevino","Villarreal","Heath","Dalton","Valencia","Callahan","Hensley",
    "Atkins","Huffman","Roy","Boyer","Shields","Lin","Hancock","Grimes","Glenn","Cline","Delacruz","Camacho","Dillon","Parrish","Neill","Melton","Booth","Kane","Berg","Harrell"
    ,"Pitts","Savage","Wiggins","Brennan","Salas","Marks","Russo","Sawyer","Baxter","Golden","Hutchinson","Liu","Walter","McDowell","Wiley","Rich","Humphrey","Johns","Koch",
    "Suarez","Hobbs","Beard","Gilmore","Ibarra","Keith","Macias","Khan","Andrade","Ware","Stephenson","Henson","Wilkerson","Dyer","McClure","Blackwell","Mercado","Tanner","Eaton"
    ,"Clay","Barron","Beasley","Neal","Preston","Small","Wu","Zamora","MacDonald","Vance","Snow","McClain","Stafford","Orozco","Barry","English","Shannon","Kline","Jacobson",
    "Woodard","Huang","Kemp","Mosley","Prince","Merritt","Hurst","Villanueva","Roach","Nolan","Lam","Yoder","McCullough","Lester","Santana","Valenzuela","Winters","Barrera",
    "Leach","Orr","Berger","McKee","Strong","Conway","Stein","Whitehead","Bullock","Escobar","Knox","Meadows","Solomon","Velez","Donnell","Kerr","Stout","Blankenship","Browning"
    ,"Kent","Lozano","Bartlett","Pruitt","Buck","Barr","Gaines","Durham","Gentry","McIntyre","Sloan","Melendez","Rocha","Herman","Sexton","Moon","Hendricks","Rangel","Stark"};
    void Start()
    {
        createdMeoples = 0;
        x = 0;
        int[] lastNameIndices = new int[maxMeoples];
        int[] maleHairStyles = {0, 1, 4};
        int[] femaleHairStyles = {2, 3};
        for(int i = 0; i < lastNameIndices.Length; i++){
            lastNameIndices[i] = -1;
        }
        while (createdMeoples < maxMeoples)
        {
            int partnership = Random.Range(0, 101);
            int lastNameIndex;
            if (partnership < singleChance)
            {
                GameObject createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                clothing meopology = createdMeople.GetComponent<clothing>();
                do{
                    lastNameIndex = Random.Range(0, lastNames.Length);
                }while(Contains(lastNameIndex, lastNameIndices));
                meopology.lastName = lastNames[lastNameIndex];
                meopology.gender = Random.Range(0, 2);
                meopology.age = Random.Range(3, 5);
                meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                int hairIndex = -1;
                if(meopology.gender == 0){
                    meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                    hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                }else if(meopology.gender == 1){
                    meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                    hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                }
                meopology.hairStyles[hairIndex].SetActive(true);
                meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                int topIndex = Random.Range(0, meopology.tops.Length);
                meopology.tops[topIndex].SetActive(true);
                meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                int botIndex = Random.Range(0, meopology.bottoms.Length);
                meopology.bottoms[botIndex].SetActive(true);
                meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                int shoeIndex = Random.Range(0, meopology.shoes.Length);
                meopology.shoes[shoeIndex].SetActive(true);
                meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                float ageScale;
                meopology.weight = Random.Range(0, 51);
                float characterScale = meopology.weight * 0.008f - 0.2f;
                if(meopology.age == 0){
                    ageScale = 0.4f;
                }else if(meopology.age == 1){
                    ageScale = 0.6f;
                }else if(meopology.age == 2){
                    ageScale = 0.8f;
                }else{
                    ageScale = 1.0f;
                }
                createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                createdMeoples++;
            }
            else if (partnership >= singleChance)
            {
                do{
                    lastNameIndex = Random.Range(0, lastNames.Length);
                }while(Contains(lastNameIndex, lastNameIndices));
                int singleParenthood = Random.Range(0, 101);
                int children = Random.Range(0, 101);
                int[] childrenAges = new int[maxKids];
                if(singleParenthood < singleParentChance){
                    GameObject createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                    clothing meopology = createdMeople.GetComponent<clothing>();
                    meopology.lastName = lastNames[lastNameIndex];
                    meopology.gender = Random.Range(0, 2);
                    meopology.age = 3;
                    meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                    meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                    meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                    int hairIndex = -1;
                    if(meopology.gender == 0){
                        meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                        hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                    }else if(meopology.gender == 1){
                        meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                        hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                    }
                    meopology.hairStyles[hairIndex].SetActive(true);
                    meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                    int topIndex = Random.Range(0, meopology.tops.Length);
                    meopology.tops[topIndex].SetActive(true);
                    meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                    int botIndex = Random.Range(0, meopology.bottoms.Length);
                    meopology.bottoms[botIndex].SetActive(true);
                    meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                    int shoeIndex = Random.Range(0, meopology.shoes.Length);
                    meopology.shoes[shoeIndex].SetActive(true);
                    meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                    float ageScale;
                    meopology.weight = Random.Range(0, 51);
                    float characterScale = meopology.weight * 0.008f - 0.2f;
                    if(meopology.age == 0){
                        ageScale = 0.4f;
                    }else if(meopology.age == 1){
                        ageScale = 0.6f;
                    }else if(meopology.age == 2){
                        ageScale = 0.8f;
                    }else{
                        ageScale = 1.0f;
                    }
                    createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                    createdMeoples++;
                    int numKids = Random.Range(0, maxKids);
                    for(int i = 0; i < numKids; i++){
                        createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                        meopology = createdMeople.GetComponent<clothing>();
                        meopology.lastName = lastNames[lastNameIndex];
                        meopology.gender = Random.Range(0, 2);
                        meopology.age = Random.Range(0, 3);
                        meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                        meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        hairIndex = -1;
                        if(meopology.gender == 0){
                            meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                            hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                        }else if(meopology.gender == 1){
                            meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                            hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                        }
                        meopology.hairStyles[hairIndex].SetActive(true);
                        meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                        topIndex = Random.Range(0, meopology.tops.Length);
                        meopology.tops[topIndex].SetActive(true);
                        meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                        botIndex = Random.Range(0, meopology.bottoms.Length);
                        meopology.bottoms[botIndex].SetActive(true);
                        meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                        shoeIndex = Random.Range(0, meopology.shoes.Length);
                        meopology.shoes[shoeIndex].SetActive(true);
                        meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                        meopology.weight = Random.Range(0, 51);
                        characterScale = meopology.weight * 0.008f - 0.2f;
                        if(meopology.age == 0){
                            ageScale = 0.4f;
                        }else if(meopology.age == 1){
                            ageScale = 0.6f;
                        }else if(meopology.age == 2){
                            ageScale = 0.8f;
                        }else{
                            ageScale = 1.0f;
                        }
                        createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                        createdMeoples++;
                    }
                }else if(children < kidChance){
                    int numKids = Random.Range(0, maxKids);
                    for(int i = 0; i < numKids; i++){
                        GameObject createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                        clothing meopology = createdMeople.GetComponent<clothing>();
                        meopology.lastName = lastNames[lastNameIndex];
                        meopology.gender = Random.Range(0, 2);
                        meopology.age = Random.Range(0, 3);
                        meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                        meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        int hairIndex = -1;
                        if(meopology.gender == 0){
                            meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                            hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                        }else if(meopology.gender == 1){
                            meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                            hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                        }
                        meopology.hairStyles[hairIndex].SetActive(true);
                        meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                        int topIndex = Random.Range(0, meopology.tops.Length);
                        meopology.tops[topIndex].SetActive(true);
                        meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                        int botIndex = Random.Range(0, meopology.bottoms.Length);
                        meopology.bottoms[botIndex].SetActive(true);
                        meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                        int shoeIndex = Random.Range(0, meopology.shoes.Length);
                        meopology.shoes[shoeIndex].SetActive(true);
                        meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                        float ageScale;
                        meopology.weight = Random.Range(0, 51);
                        float characterScale = meopology.weight * 0.008f - 0.2f;
                        if(meopology.age == 0){
                            ageScale = 0.4f;
                        }else if(meopology.age == 1){
                            ageScale = 0.6f;
                        }else if(meopology.age == 2){
                            ageScale = 0.8f;
                        }else{
                            ageScale = 1.0f;
                        }
                        createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                        createdMeoples++;
                    }
                    int[] coupleGender = {0, 1};
                    int coupleAge = 3;
                    for(int i = 0; i < coupleGender.Length; i++){
                        GameObject createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                        clothing meopology = createdMeople.GetComponent<clothing>();
                        meopology.lastName = lastNames[lastNameIndex];
                        meopology.gender = coupleGender[i];
                        meopology.age = coupleAge;
                        meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                        meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        int hairIndex = -1;
                        if(meopology.gender == 0){
                            meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                            hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                        }else if(meopology.gender == 1){
                            meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                            hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                        }
                        meopology.hairStyles[hairIndex].SetActive(true);
                        meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                        int topIndex = Random.Range(0, meopology.tops.Length);
                        meopology.tops[topIndex].SetActive(true);
                        meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                        int botIndex = Random.Range(0, meopology.bottoms.Length);
                        meopology.bottoms[botIndex].SetActive(true);
                        meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                        int shoeIndex = Random.Range(0, meopology.shoes.Length);
                        meopology.shoes[shoeIndex].SetActive(true);
                        meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                        float ageScale;
                        meopology.weight = Random.Range(0, 51);
                        float characterScale = meopology.weight * 0.008f - 0.2f;
                        if(meopology.age == 0){
                            ageScale = 0.4f;
                        }else if(meopology.age == 1){
                            ageScale = 0.6f;
                        }else if(meopology.age == 2){
                            ageScale = 0.8f;
                        }else{
                            ageScale = 1.0f;
                        }
                        createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                        createdMeoples++;
                    }
                }else{
                    int coupleAge = Random.Range(3, 5);
                    int[] coupleGender = {0, 1};
                    for(int i = 0; i < coupleGender.Length; i++){
                        GameObject createdMeople = Instantiate(meoplePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
                        clothing meopology = createdMeople.GetComponent<clothing>();
                        meopology.lastName = lastNames[lastNameIndex];
                        meopology.gender = coupleGender[i];
                        meopology.age = coupleAge;
                        meopology.skinColor = meopology.skin_textures[Random.Range(0, meopology.skin_textures.Length)];
                        meopology.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        meopology.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopology.skinColor;
                        int hairIndex = -1;
                        if(meopology.gender == 0){
                            meopology.firstName = maleNames[Random.Range(0, maleNames.Length)];
                            hairIndex = maleHairStyles[Random.Range(0, maleHairStyles.Length)];
                        }else if(meopology.gender == 1){
                            meopology.firstName = femaleNames[Random.Range(0, femaleNames.Length)];
                            hairIndex = femaleHairStyles[Random.Range(0, femaleHairStyles.Length)];
                        }
                        meopology.hairStyles[hairIndex].SetActive(true);
                        meopology.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.hairTextures[hairIndex][Random.Range(0, meopology.hairTextures[hairIndex].Length)];
                        int topIndex = Random.Range(0, meopology.tops.Length);
                        meopology.tops[topIndex].SetActive(true);
                        meopology.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.topTextures[topIndex][Random.Range(0, meopology.topTextures[topIndex].Length)];
                        int botIndex = Random.Range(0, meopology.bottoms.Length);
                        meopology.bottoms[botIndex].SetActive(true);
                        meopology.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.bottomTextures[botIndex][Random.Range(0, meopology.bottomTextures[botIndex].Length)];
                        int shoeIndex = Random.Range(0, meopology.shoes.Length);
                        meopology.shoes[shoeIndex].SetActive(true);
                        meopology.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopology.shoeTextures[shoeIndex][Random.Range(0, meopology.shoeTextures[shoeIndex].Length)];
                        float ageScale;
                        meopology.weight = Random.Range(0, 51);
                        float characterScale = meopology.weight * 0.008f - 0.2f;
                        if(meopology.age == 0){
                            ageScale = 0.4f;
                        }else if(meopology.age == 1){
                            ageScale = 0.6f;
                        }else if(meopology.age == 2){
                            ageScale = 0.8f;
                        }else{
                            ageScale = 1.0f;
                        }
                        createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
                        createdMeoples++;
                    }
                }
            }
            x+=5;
        }
    }
    private bool Contains(int a, int[] b)
    {
        for(int i = 0; i < b.Length; i++){
            if(a == b[i]){
                return true;
            }
        }
        return false;
    }
    /**
    for(int i = 0; i < meopleData.Length; i++){
            GameObject createdMeople = Instantiate(meople, new Vector3(i, 0, 0), Quaternion.identity);
            clothing meopleStats = createdMeople.GetComponent<clothing>();
            meopleStats.firstName = meopleData[i].GetFirstName();
            meopleStats.lastName = meopleData[i].GetLastName();
            meopleStats.gender = meopleData[i].GetGender();
            meopleStats.age = meopleData[i].GetAge();
            meopleStats.skinColor = meopleStats.skin_textures[meopleData[i].GetSkinColor()];
            meopleStats.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopleStats.skinColor;
            meopleStats.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopleStats.skinColor;
            int hairIndex = meopleData[i].GetHair()[0];
            int hairTextureIndex = meopleData[i].GetHair()[1];
            meopleStats.hairStyles[hairIndex].SetActive(true);
            meopleStats.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[hairIndex][hairTextureIndex];
            int topIndex = meopleData[i].GetTop()[0];
            int topTextureIndex = meopleData[i].GetTop()[1];
            meopleStats.tops[topIndex].SetActive(true);
            meopleStats.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.topTextures[topIndex][topTextureIndex];
            int botIndex = meopleData[i].GetBot()[0];
            int botTextureIndex = meopleData[i].GetBot()[1];
            meopleStats.bottoms[botIndex].SetActive(true);
            meopleStats.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[botIndex][botTextureIndex];
            int shoeIndex = meopleData[i].GetShoe()[0];
            int shoeTextureIndex = meopleData[i].GetShoe()[1];
            meopleStats.shoes[shoeIndex].SetActive(true);
            meopleStats.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[shoeIndex][shoeTextureIndex];
            meopleStats.weight = meopleData[i].GetWeight();
            float ageScale;
            float characterScale = meopleStats.weight * 0.008f - 0.2f;
            if(meopleStats.age == 0){
                ageScale = 0.4f;
            }else if(meopleStats.age == 1){
                ageScale = 0.6f;
            }else if(meopleStats.age == 2){
                ageScale = 0.8f;
            }else{
                ageScale = 1.0f;
            }
            createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);*/
}
