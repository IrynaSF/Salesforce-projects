import { LightningElement, wire } from 'lwc';
import getActiveJobs from '@salesforce/apex/ScheduledJobsMonitorController.getActiveJobs';

export default class ScheduledJobsMonitor extends LightningElement {
    jobs = [];
    error;

    // @wire — автоматически загружает данные
    @wire(getActiveJobs)
    wiredJobs({ data, error }) {
        // если data — сохрани в jobs
        // если error — сохрани в error и выведи в console.error
        if (data) {
            // Сохраняем данные, если они пришли успешно
            this.jobs = data;
            this.error = undefined;
        } else if (error) {
            // Сохраняем/обрабатываем ошибку
            this.error = error;
            this.jobs = [];
            console.error('Ошибка загрузки:', error);
        }
    }


     // Геттер — преобразует вложенные поля
    get formattedJobs() {
        return this.jobs.map(job => ({
            Id:             job.Id,
            jobName:        job.CronJobDetail.Name,
            NextFireTime:   job.NextFireTime,
            TimesTriggered: job.TimesTriggered,
            CronExpression: job.CronExpression
        }));
    }

    // Геттер — количество jobs
    get totalJobs() {
        // верни количество
        return this.jobs ? this.jobs.length : 0;
    }

    // Геттер — список пустой?
    get isEmpty() {
        // верни true если пустой
         return !this.jobs || this.jobs.length === 0;
    }
}