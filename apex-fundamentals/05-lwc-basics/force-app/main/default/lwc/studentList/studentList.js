import { LightningElement } from 'lwc';

export default class StudentList extends LightningElement {

    // Class property: holds the list of students
    // Each student is an object with the fields id, name, grade, active
    students = [
        { id: 1, name: 'Linda', grade: 85, active: true  },
        { id: 2, name: 'Bob',   grade: 42, active: false },
        { id: 3, name: 'Clara', grade: 91, active: true  },
    ];

    // ─────────────────────────────────────────
    // Method 1: add a new student
    // Called when the "Add David" button is clicked
    // ─────────────────────────────────────────
    handleAdd() {
        // Create the new student object
        // const: can't be reassigned, lives only in this method
        const newStudent = { id: 4, name: 'David', grade: 75, active: true };

        // [...this.students]: copy all existing students
        // newStudent: add David to the end of the copy
        // this.students = : assign a NEW array → LWC sees the change
        this.students = [...this.students, newStudent];

        // Log the whole array after adding
        console.log('handleAdd:', this.students);
    }

    // ─────────────────────────────────────────
    // Method 2: delete a student by id
    // Called when the "Delete" button is clicked
    // event: the event object, contains data about the clicked button
    // ─────────────────────────────────────────
    handleDelete(event) {
        // event.target: the button that was clicked
        // .dataset.id: read the data-id attribute from the button
        // Number(): convert the string '2' to the number 2
        const idToDelete = Number(event.target.dataset.id);

        // filter(): goes over each student
        // keeps only those whose id does NOT match idToDelete
        // creates a NEW array without the deleted student
        this.students = this.students.filter(student => student.id !== idToDelete);

        // Log the array after deletion
        console.log('handleDelete:', this.students);
    }

    // ─────────────────────────────────────────
    // Method 3: update Linda's grade to 95
    // Called when the "Update Linda" button is clicked
    // ─────────────────────────────────────────
    handleUpdate() {
        // map(): goes over each student
        // creates a NEW array with the changes
        // ternary operator ? : if Linda → change, otherwise → keep
        this.students = this.students.map(student =>
            // student.name === 'Linda': check the current student
            student.name === 'Linda'
                // true → { ...student } copy all fields, grade: 95 overwrites the grade
                ? { ...student, grade: 95 }
                // false → return the student unchanged
                : student
        );

        // Log the array after the update
        console.log('handleUpdate:', this.students);
    }

    // ─────────────────────────────────────────
    // Method 4: sort students by grade
    // Called when the "Sort by Grade" button is clicked
    // ─────────────────────────────────────────
    handleSort() {
        // [...this.students]: create a COPY of the array
        // .sort(): sort the copy, the original is untouched
        // (a, b): two neighbouring students to compare
        // b.grade - a.grade: a positive number → b before a → descending
        this.students = [...this.students].sort((a, b) => b.grade - a.grade);

        // Log the array after sorting
        console.log('handleSort:', this.students);
    }
}