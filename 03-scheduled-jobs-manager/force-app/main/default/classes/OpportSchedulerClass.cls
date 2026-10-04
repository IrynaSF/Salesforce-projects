//это клас планировщик который отвечет за фоновую работу
//его задача: проснуться в нужное время и выполнить работу
//его особенность : он должен реализовать интерфес System.Schedulable
//Он живет глубоко в систеие SF и не умеет напрямую общаться с кнопками на экране
public class OpportSchedulerClass implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        
        // 1. Прямой и понятный запрос (ищем закрытые вчера сделки)
        List<Opportunity> closedOpps = [
            SELECT Name, AccountId, Amount, OwnerId 
            FROM Opportunity 
            WHERE StageName = 'Closed Won' AND CloseDate = YESTERDAY
        ];
        
        // 2. Корзина для новых сделок
        //Создаём пустой список куда будем складывать
        // новые Follow-up Opportunity перед вставкой в базу.
        List<Opportunity> newOpps = new List<Opportunity>();
        
        // 3. Цикл переноса данных
        //Цикл for берет список наших вчерашних сделок (closedOpps) и начинает перебирать их по одной.
        // Каждую текущую сделку в цикле мы называем переменной opp.
        //Для каждой закрытой Opportunity создаём новую Follow-up:
        for (Opportunity opp : closedOpps) {
            newOpps.add(new Opportunity(
                Name = 'Follow-up: ' + opp.Name,
                AccountId = opp.AccountId,
                Amount = opp.Amount,
                OwnerId = opp.OwnerId,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(90)
            ));
        }
        
        // 4. Сохранение в базу (если корзина не пустая)
        if (!newOpps.isEmpty()) {
            insert newOpps;
        }
    }
}


//Сценарий
//аждый день система автоматически находит Opportunity которые закрылись как 
//"Closed Won" за последние 30 дней и создаёт новую Follow-up Opportunity для повторной 
//продажи тому же клиенту.

//использовала фильтр YESTERDAY вместо LAST_N_DAYS:30, потому что планировщик работает каждый день. 
//Если искать за 30 дней, то код будет находить одни и те же сделки повторно и создавать дубликаты.
// Фильтр по вчерашнему дню гарантирует, 
//что каждая закрытая сделка получит строго один Follow-up»

//В определенное время планировщик просыпается ➡️ делает моментальный снимок вчерашних успешных сделок ➡️ 
//за доли секунды перебирает их в цикле, создавая копии ➡️ сохраняет их в базу ➡️ 
//снова засыпает до следующей ночи.Если в какой-то из дней вчера не было закрытых сделок, 
//запрос вернет 0 записей, 
//цикл просто не начнется, и код изящно завершит работу, ничего не сломав.
