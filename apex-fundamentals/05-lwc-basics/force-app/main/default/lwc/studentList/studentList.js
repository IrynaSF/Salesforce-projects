import { LightningElement } from 'lwc';

export default class StudentList extends LightningElement {

    // Переменная класса — хранит список студентов
    // Каждый студент это объект с полями: id, name, grade, active
    students = [
        { id: 1, name: 'Linda', grade: 85, active: true  },
        { id: 2, name: 'Bob',   grade: 42, active: false },
        { id: 3, name: 'Clara', grade: 91, active: true  },
    ];

    // ─────────────────────────────────────────
    // Метод 1 — Добавить нового студента
    // Вызывается когда нажали кнопку "Add David"
    // ─────────────────────────────────────────
    handleAdd() {
        // Создаём объект нового студента
        // const — нельзя переназначить, живёт только в этом методе
        const newStudent = { id: 4, name: 'David', grade: 75, active: true };

        // [...this.students] — копируем всех существующих студентов
        // newStudent — добавляем Дэвида в конец копии
        // this.students = — присваиваем НОВЫЙ массив → LWC видит изменение
        this.students = [...this.students, newStudent];

        // Выводим в консоль весь массив после добавления
        console.log('handleAdd:', this.students);
    }

    // ─────────────────────────────────────────
    // Метод 2 — Удалить студента по id
    // Вызывается когда нажали кнопку "Delete"
    // event — объект события, содержит данные о нажатой кнопке
    // ─────────────────────────────────────────
    handleDelete(event) {
        // event.target — кнопка которую нажали
        // .dataset.id — читаем атрибут data-id с кнопки
        // Number() — конвертируем строку '2' в число 2
        const idToDelete = Number(event.target.dataset.id);

        // filter() — проходит по каждому студенту
        // оставляет только тех у кого id НЕ совпадает с idToDelete
        // создаёт НОВЫЙ массив без удалённого студента
        this.students = this.students.filter(student => student.id !== idToDelete);

        // Выводим в консоль массив после удаления
        console.log('handleDelete:', this.students);
    }

    // ─────────────────────────────────────────
    // Метод 3 — Обновить оценку у Linda на 95
    // Вызывается когда нажали кнопку "Update Linda"
    // ─────────────────────────────────────────
    handleUpdate() {
        // map() — проходит по каждому студенту
        // создаёт НОВЫЙ массив с изменениями
        // тернарный оператор ? : — если Linda → меняем, иначе → оставляем
        this.students = this.students.map(student =>
            // student.name === 'Linda' — проверяем текущего студента
            student.name === 'Linda'
                // true → { ...student } копируем все поля, grade: 95 перезаписываем оценку
                ? { ...student, grade: 95 }
                // false → возвращаем студента без изменений
                : student
        );

        // Выводим в консоль массив после обновления
        console.log('handleUpdate:', this.students);
    }

    // ─────────────────────────────────────────
    // Метод 4 — Отсортировать студентов по оценке
    // Вызывается когда нажали кнопку "Sort by Grade"
    // ─────────────────────────────────────────
    handleSort() {
        // [...this.students] — создаём КОПИЮ массива
        // .sort() — сортируем копию, оригинал не трогаем
        // (a, b) — два соседних студента для сравнения
        // b.grade - a.grade — положительное число → b перед a → убывание
        this.students = [...this.students].sort((a, b) => b.grade - a.grade);

        // Выводим в консоль массив после сортировки
        console.log('handleSort:', this.students);
    }
}