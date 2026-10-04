public with sharing class TernerniiOperator {
    public static String getAccountTier(Decimal annualRevenue){

         String tier = (annualRevenue >= 1000000) ? 'Enterprise' : 'SMB';
         System.debug('Account tier: ' + tier);
     
         return tier;
       
    }
    
}



//(revenue >= 1000000) — условие (проверяем)
///? — "если условие истинно — то..."
//'Enterprise' — значение если true
//: — "иначе..."
//'SMB' — значение если false

//Тернарный оператор 
//Это сокращённая запись if/else в одну строку. Используется когда нужно просто присвоить одно из двух значений переменной.
//Схема:
//тип переменная = условие ? значение_если_true : значение_если_false;
//Когда использовать:
///Когда логика простая — просто выбрать одно из двух значений. 
//Если логика сложная (несколько действий внутри) — лучше обычный if/else.

//Задание 2 — тернарный оператор
//Напиши метод getAccountTier(Decimal annualRevenue):
///Принимает число annualRevenue
//Через тернарный оператор определяет уровень клиента:
//если annualRevenue >= 1000000 → 'Enterprise'
//иначе → 'SMB'
