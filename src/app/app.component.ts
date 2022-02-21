import { BreakpointObserver } from '@angular/cdk/layout';
import { Component, ViewChild, AfterViewInit } from '@angular/core';
import { MatSidenav } from '@angular/material/sidenav';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.less']
})
export class AppComponent implements AfterViewInit{
  @ViewChild(MatSidenav)
  sidenav!: MatSidenav;
  toggleSideNav() {
    console.log(this.sidenav.opened)
    this.sidenav.opened ? this.sidenav.close() : this.sidenav.open();
  }
  constructor(private observer: BreakpointObserver) {}
  update() {
    const now = new Date();
    console.info("Starting update at:", now.toUTCString());
    console.time("Update");
    // @todo: request updated data from the "server"
    console.timeEnd("Update");
  }
  ngAfterViewInit() {
    this.observer.observe(['(max-width: 800px)']).subscribe((res) => {
      setTimeout(() => {

        if (res.matches) {
          this.sidenav.mode = 'over';
          this.sidenav.close();
        } else {
          this.sidenav.mode = 'side';
          this.sidenav.open();
        }
  
      }, 0);
    });
  }
}
