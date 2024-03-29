library(dplyr)

#verinin genel g�r�n�m�n� incelemek i�in kullan�l�r. 
glimpse(alexa)


#verinin sat�r say�s� kadar sat�r de�eri atad�k. 
amazon_alexa=data.frame(line=1:3150,amazon_alexa)


#veride s�tun isimlerini t�rk�ele�tirdik. 

alexa= amazon_alexa %>%
  select(yorum_numarasi=line,
         degerlendirme_puani=rating,
         tarih=date,
         urun_model=variation,
         yorumlar=verified_reviews,
         geri_donus=feedback)


#t�m yorumlar� k���k harfe �evirdik. 
alexa$yorumlar=sapply(alexa$yorumlar,tolower)

#Birden fazla bo�luk var ise o bo�luklar�n silinmesi
library(tm)
alexa$yorumlar=sapply(alexa$yorumlar,stripWhitespace)

#noktalama i�aretlerinin metinden kald�r�lmas�
alexa$yorumlar=sapply(alexa$yorumlar,removePunctuation)  


#istenmeyen kelimelerin listelenmesi
library(tidytext)
stopwords()

#bizim eklemek isteyece�imiz istemedi�imiz kelimeler olabilir onlar� eklemek i�in;

kaldirilacak_kelimeler<- c("echo","amazon","alexa","device",
                           "sound","time","play","home","bedroom",
                           "price","purchase")


alexa_temiz= alexa %>% 
  unnest_tokens(word, yorumlar) %>%                 #verinin kelimelere ayr�lmas�
  anti_join(stop_words) %>%                         #stop words kelimelerin kald�r�lmas�
  filter(!word %in% kaldirilacak_kelimeler) %>%     #kendi belirledi�imiz istemedi�imiz kelimeler
  filter(nchar(word)>3)                             #�� harften k���k kelimelerin kald�r�lmas�

#en �ok gecen kelimeleri sayan fonksiyon

alexa_kelime_sayisi=alexa_temiz %>%
  count(word,sort=TRUE)


#geli�mi� kelime bulutu

library(wordcloud2)
wordcloud2(alexa_kelime_sayisi[1:200, ],size=1 )


#DUYGU ANAL�Z� ADIMLARI
get_sentiments("bing")
get_sentiments("afinn")
get_sentiments("nrc")

#bing s�zl���n�n veriye dahil edilmesi
alexa_duygu_bing <- alexa_temiz %>%
  inner_join(get_sentiments("bing"))

#nrc s�zl���n�n veriye dahil edilmesi
alexa_duygu_nrc <- alexa_temiz %>%
  inner_join(get_sentiments("nrc"))

#afinn s�zl���n�n veriye dahil edilmesi
alexa_duygu_afinn <- alexa_temiz %>%
  inner_join(get_sentiments("afinn"))

library(dplyr)
library(ggplot2)

options(repr.plot.width=5, repr.plot.height=4)
tilt_theme <- theme(axis.text.x=element_text(angle=45, hjust=1))
alexa_duygu_bing %>%
  group_by(yorum_numarasi) %>%
  top_n(1) %>%
  ggplot(aes(x=sentiment,y=yorum_numarasi,fill=urun_model)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=urun_model), vjust=1.6, color="black", size=3)+
  ggtitle("Bing s�zl���ne g�re yorumlar�n duygu da��l�mlar�") +
  tilt_theme






