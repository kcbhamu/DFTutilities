temp=25.0  # temperature (C)
windspeed=3.0   # Wind speed (m/s)
humidity=00.0  # humidity (%)

import math
class AppTemp:
    def __init__(self,temp,windspeed,humidity):
        self.temp=temp
        self.windspeed=windspeed
        self.humidity=humidity
    def WaterP(self):  # Water Pressure
        return (self.humidity / 100)*6.105*math.exp( (17.27*self.temp) / (237.7 + self.temp) )
    def AppT(self):
        return (1.04*self.temp) + (0.2*self.WaterP()) - (0.65* self.windspeed) - 2.7       

if __name__=='__main__':
    TaCal=AppTemp(temp=temp,windspeed=windspeed,humidity=humidity)
    P=TaCal.WaterP()
    Ta=TaCal.AppT()
    print('>> Input conditions:\n')
    print('Temperature= %6.2f (C)\nWind Speed= %6.2f (m/s)\nHumidity= %6.2f (%%)\n' % (temp, windspeed, humidity) )
    print('>> Output results:\n')
    print('Water Pressre= %6.2f (hPa) \nApparent Temperature= %6.2f (C)' % (P,Ta))
    
