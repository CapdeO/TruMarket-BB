import React from 'react'
import Swal from 'sweetalert2'


const WaitingTransaction = ({ title, text, active }) => {
    if (active) {
        Swal.fire({
            title: title,
            html: text,
            allowEscapeKey: false,
            allowOutsideClick: false,
            didOpen: () => {
                Swal.showLoading();
            },
        });
    } else {
        Swal.close();
    }
};

export default WaitingTransaction;