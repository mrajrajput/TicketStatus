package TicketStatus.TicketStatus;

/*import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.when;

import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;*/
/*
import com.constants.common.Constants;
import com.staus.common.StatusFinder;*/

/*@RunWith(PowerMockRunner.class)
@PrepareForTest({ FacesContext.class })*/
public class StatusFinderTest {
/*	@Before
	public void initMocks() {
		MockitoAnnotations.initMocks(this);
		// Use Mockito to make our Mocked FacesContext look more like a real one
		// while making it returns other Mocked objects

		// mock all static methods of FacesContext using PowerMockito
		PowerMockito.mockStatic(FacesContext.class);
		when(FacesContext.getCurrentInstance()).thenReturn(facesContext);
		when(facesContext.getExternalContext()).thenReturn(externalContext);

		statusFinder.init();
	}

	@Mock
	private FacesContext facesContext;
	@Mock
	private ExternalContext externalContext;

	@InjectMocks
	StatusFinder statusFinder = new StatusFinder();

	@Test
	public void testProjects() {
		assertEquals(Constants.WelcomePage, statusFinder.status());
	}

	@Test
	public void testStatus() {
		fail("Not yet implement" + "ed");
	}*/
}