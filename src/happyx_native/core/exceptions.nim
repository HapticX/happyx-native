## # Exceptions
## 
## Provides all exceptions
## 


type
  BrowserNotFound* = object of CatchableError  ## Base browser not found exception
  ChromeNotFound* = object of BrowserNotFound  ## Chrome browser not found exception
  YandexNotFound* = object of BrowserNotFound  ## Yandex browser not found exception
  EdgeNotFound* = object of BrowserNotFound  ## Edge browser not found exception
  MozillaNotFound* = object of BrowserNotFound  ## Mozilla browser not found exception
